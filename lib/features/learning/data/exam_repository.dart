import 'dart:async';
import 'package:eduquest/features/learning/data/learning_scope_repository.dart';
import 'package:eduquest/features/learning/domain/exam_category.dart';
import 'package:eduquest/features/learning/domain/exam_entry.dart';
import 'package:eduquest/features/learning/domain/learning_subject.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eduquest/shared/realtime/cache_signal.dart';

class ExamRepository {
  final _scopeRepo = LearningScopeRepository();
  final _local = LocalJsonCache();
  static final Map<String, List<LearningSubject>> _subjectCache = {};
  static final Map<String, List<ExamEntry>> _paperCache = {};


  static void clearMemory() {
    _subjectCache.clear();
    _paperCache.clear();
  }

  static void evictKeys(CacheTargets t) {
    if (t.exact.any((k) => k.startsWith('exam:')) ||
        t.prefixes.any((p) => p.startsWith('exam:'))) {
      clearMemory();
    }
  }

  Future<bool> hasSubjectsCache(ExamCategory category) async {
    final s = await _scopeRepo.current();
    if (s == null || !s.hasSeries) return false;
    final memKey = '${category.name}:${s.countryId}:${s.levelId}:${s.seriesId}';
    if (_subjectCache.containsKey(memKey)) return true;
    return _local.hasKey('exam:subjects:$memKey');
  }

  Future<bool> hasPapersCache({
    required String subjectId,
    required ExamCategory category,
  }) async {
    final s = await _scopeRepo.current();
    if (s == null || !s.hasSeries) return false;
    final memKey =
        '${category.name}:${s.countryId}:${s.levelId}:${s.seriesId}:$subjectId';
    if (_paperCache.containsKey(memKey)) return true;
    return _local.hasKey('exam:papers:$memKey');
  }

  List<ExamEntry>? peekPapers({
    required String subjectId,
    required ExamCategory category,
  }) {
    for (final e in _paperCache.entries) {
      if (e.key.startsWith('${category.name}:') &&
          e.key.endsWith(':$subjectId')) {
        return e.value;
      }
    }
    return null;
  }

  Future<List<LearningSubject>> subjects(
    ExamCategory category, {
    bool forceRefresh = false,
  }) async {
    final s = await _scopeRepo.current();
    if (s == null || !s.hasSeries) return const [];
    final key = '${category.name}:${s.countryId}:${s.levelId}:${s.seriesId}';
    final cacheKey = 'exam:subjects:$key';
    final cached = _subjectCache[key];
    // Un cache VIDE ne doit jamais suppr le refetch : il peut dater d'avant l'ajout
    // du contenu (ex. annales chargees apres coup) -> on le traite comme un cache-miss.
    if (cached != null && cached.isNotEmpty && !forceRefresh) {
      return cached;
    }
    final localRows = forceRefresh ? null : await _local.readList(cacheKey);
    if (localRows != null && localRows.isNotEmpty) {
      final out = localRows
          .map(
            (e) => LearningSubject(
              id: '${e['id']}',
              code: '${e['code']}',
              label: '${e['label']}',
            ),
          )
          .toList();
      _subjectCache[key] = out;
      return out;
    }
    if (!Env.hasSupabase) return const [];
    final fresh = await _refreshSubjects(
      s.countryId,
      s.levelId,
      s.seriesId!,
      category,
      key,
    );
    if (fresh != null) return fresh;
    return cached ?? const [];
  }

  Future<List<LearningSubject>?> _refreshSubjects(
    String countryId,
    String levelId,
    String seriesId,
    ExamCategory category,
    String key,
  ) async {
    try {
      final rows = await Supabase.instance.client.rpc(
        'list_exam_subjects',
        params: {
          'p_country_id': countryId,
          'p_level_id': levelId,
          'p_series_id': seriesId,
          'p_category': category.name,
        },
      );
      final out = (rows as List)
          .map(
            (e) => LearningSubject(
              id: '${e['id']}',
              code: '${e['code']}',
              label: '${e['label']}',
            ),
          )
          .toList();
      _subjectCache[key] = out;
      await _local.writeList(
        'exam:subjects:$key',
        out.map((e) => {'id': e.id, 'code': e.code, 'label': e.label}).toList(),
      );
      return out;
    } catch (_) {
      return null;
    }
  }

  Future<List<ExamEntry>> listBySubject({
    required String subjectId,
    required ExamCategory category,
    bool forceRefresh = false,
  }) async {
    final s = await _scopeRepo.current();
    if (s == null || !s.hasSeries) return const [];
    final key =
        '${category.name}:${s.countryId}:${s.levelId}:${s.seriesId}:$subjectId';
    final cacheKey = 'exam:papers:$key';
    final cached = _paperCache[key];
    if (cached != null && cached.isNotEmpty && !forceRefresh) {
      return cached;
    }
    final localRows = forceRefresh ? null : await _local.readList(cacheKey);
    if (localRows != null && localRows.isNotEmpty) {
      final out = localRows
          .map(
            (e) => ExamEntry(
              id: '${e['id']}',
              title: '${e['title']}',
              paperUrl: '${e['paperUrl']}',
              correctionUrl: e['correctionUrl']?.toString(),
              semester: e['semester']?.toString(),
            ),
          )
          .toList();
      _paperCache[key] = out;
      return out;
    }
    if (!Env.hasSupabase) return const [];
    final fresh = await _refreshPapers(
      s.countryId,
      s.levelId,
      s.seriesId!,
      subjectId,
      category,
      key,
    );
    if (fresh != null) return fresh;
    return cached ?? const [];
  }

  Future<List<ExamEntry>?> _refreshPapers(
    String countryId,
    String levelId,
    String seriesId,
    String subjectId,
    ExamCategory category,
    String key,
  ) async {
    try {
      final rows = await Supabase.instance.client.rpc(
        'list_exam_papers',
        params: {
          'p_country_id': countryId,
          'p_level_id': levelId,
          'p_series_id': seriesId,
          'p_subject_id': subjectId,
          'p_category': category.name,
        },
      );
      final out = (rows as List)
          .map((e) {
            // `semester`/`source_school` sont toujours nuls sur les sujets nationaux
            // (BAC/Probatoire) : on affiche le niveau d'examen à la place, plus
            // parlant que le placeholder "Session • Source locale".
            final title = category == ExamCategory.national
                ? '${e['year'] ?? 'Sans année'} • ${e['exam_level_label'] ?? 'Examen national'}'
                : '${e['year'] ?? 'Sans année'} • ${e['semester'] ?? 'Session'} • ${e['source_school'] ?? 'Source locale'}';
            return ExamEntry(
              id: '${e['id']}',
              title: title,
              paperUrl: '${e['paper_path'] ?? ''}',
              correctionUrl: e['correction_path']?.toString(),
              semester: e['semester']?.toString(),
            );
          })
          .where((e) => e.paperUrl.isNotEmpty)
          .toList();
      _paperCache[key] = out;
      await _local.writeList(
        'exam:papers:$key',
        out
            .map(
              (e) => {
                'id': e.id,
                'title': e.title,
                'paperUrl': e.paperUrl,
                'correctionUrl': e.correctionUrl,
                'semester': e.semester,
              },
            )
            .toList(),
      );
      return out;
    } catch (_) {
      return null;
    }
  }
}
