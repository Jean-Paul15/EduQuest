import 'dart:async';
import 'package:eduquest/features/learning/data/learning_scope_repository.dart';
import 'package:eduquest/features/learning/domain/exam_category.dart';
import 'package:eduquest/features/learning/domain/exam_entry.dart';
import 'package:eduquest/features/learning/domain/learning_subject.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExamRepository {
  final _scopeRepo = LearningScopeRepository();
  final _local = LocalJsonCache();
  static final Map<String, List<LearningSubject>> _subjectCache = {};
  static final Map<String, List<ExamEntry>> _paperCache = {};

  static void clearMemory() {
    _subjectCache.clear();
    _paperCache.clear();
  }

  Future<bool> hasSubjectsCache(ExamCategory category) async {
    final s = await _scopeRepo.current();
    if (s == null) return false;
    return _local.hasKey(
      'exam:subjects:${category.name}:${s.countryId}:${s.levelId}',
    );
  }

  Future<bool> hasPapersCache({
    required String subjectId,
    required ExamCategory category,
  }) async {
    final s = await _scopeRepo.current();
    if (s == null) return false;
    return _local.hasKey(
      'exam:papers:${category.name}:${s.countryId}:${s.levelId}:$subjectId',
    );
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

  Future<List<LearningSubject>> subjects(ExamCategory category) async {
    final s = await _scopeRepo.current();
    if (s == null) return const [];
    final key = '${category.name}:${s.countryId}:${s.levelId}';
    final cached = _subjectCache[key];
    if (cached != null) {
      if (Env.hasSupabase) {
        unawaited(_refreshSubjects(s.countryId, s.levelId, category, key));
      }
      return cached;
    }
    final cacheKey = 'exam:subjects:$key';
    final localRows = await _local.readList(cacheKey);
    if (localRows != null) {
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
      if (Env.hasSupabase) {
        unawaited(_refreshSubjects(s.countryId, s.levelId, category, key));
      }
      return out;
    }
    if (!Env.hasSupabase) return const [];
    final fresh = await _refreshSubjects(s.countryId, s.levelId, category, key);
    return fresh ?? const [];
  }

  Future<List<LearningSubject>?> _refreshSubjects(
    String countryId,
    String levelId,
    ExamCategory category,
    String key,
  ) async {
    try {
      final rows = switch (category) {
        ExamCategory.national =>
          await Supabase.instance.client
              .from('exam_papers')
              .select('subject_id')
              .eq('country_id', countryId)
              .eq('education_level_id', levelId)
              .eq('is_national_exam', true),
        ExamCategory.mock =>
          await Supabase.instance.client
              .from('exam_papers')
              .select('subject_id')
              .eq('country_id', countryId)
              .eq('education_level_id', levelId)
              .eq('is_national_exam', false)
              .isFilter('semester', null),
        ExamCategory.epreuve =>
          await Supabase.instance.client
              .from('exam_papers')
              .select('subject_id')
              .eq('country_id', countryId)
              .eq('education_level_id', levelId)
              .not('semester', 'is', null),
      };
      final ids = (rows as List)
          .map((e) => '${e['subject_id']}')
          .toSet()
          .toList();
      if (ids.isEmpty) return const [];
      final sub = await Supabase.instance.client
          .from('subjects')
          .select('id,code,label')
          .inFilter('id', ids)
          .order('label');
      final out = (sub as List)
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
  }) async {
    final s = await _scopeRepo.current();
    if (s == null) return const [];
    final key = '${category.name}:${s.countryId}:${s.levelId}:$subjectId';
    final cached = _paperCache[key];
    if (cached != null) {
      if (Env.hasSupabase) {
        unawaited(
          _refreshPapers(s.countryId, s.levelId, subjectId, category, key),
        );
      }
      return cached;
    }
    final cacheKey = 'exam:papers:$key';
    final localRows = await _local.readList(cacheKey);
    if (localRows != null) {
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
      if (Env.hasSupabase) {
        unawaited(
          _refreshPapers(s.countryId, s.levelId, subjectId, category, key),
        );
      }
      return out;
    }
    if (!Env.hasSupabase) return const [];
    final fresh = await _refreshPapers(
      s.countryId,
      s.levelId,
      subjectId,
      category,
      key,
    );
    return fresh ?? const [];
  }

  Future<List<ExamEntry>?> _refreshPapers(
    String countryId,
    String levelId,
    String subjectId,
    ExamCategory category,
    String key,
  ) async {
    try {
      final rows = switch (category) {
        ExamCategory.national =>
          await Supabase.instance.client
              .from('exam_papers')
              .select(
                'id,year,semester,source_school,paper_path,correction_path',
              )
              .eq('country_id', countryId)
              .eq('education_level_id', levelId)
              .eq('subject_id', subjectId)
              .eq('is_national_exam', true)
              .order('year', ascending: false),
        ExamCategory.mock =>
          await Supabase.instance.client
              .from('exam_papers')
              .select(
                'id,year,semester,source_school,paper_path,correction_path',
              )
              .eq('country_id', countryId)
              .eq('education_level_id', levelId)
              .eq('subject_id', subjectId)
              .eq('is_national_exam', false)
              .isFilter('semester', null)
              .order('year', ascending: false),
        ExamCategory.epreuve =>
          await Supabase.instance.client
              .from('exam_papers')
              .select(
                'id,year,semester,source_school,paper_path,correction_path',
              )
              .eq('country_id', countryId)
              .eq('education_level_id', levelId)
              .eq('subject_id', subjectId)
              .not('semester', 'is', null)
              .order('year', ascending: false),
      };
      final out = (rows as List)
          .map((e) {
            final title =
                '${e['year'] ?? 'Sans année'} • ${e['semester'] ?? 'Session'} • ${e['source_school'] ?? 'Source locale'}';
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
