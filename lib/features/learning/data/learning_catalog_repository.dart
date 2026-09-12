import 'dart:async';
import 'package:eduquest/features/learning/data/learning_scope_repository.dart';
import 'package:eduquest/features/learning/domain/learning_chapter.dart';
import 'package:eduquest/features/learning/domain/learning_subject.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eduquest/shared/realtime/cache_signal.dart';

class LearningCatalogRepository {
  final _scopeRepo = LearningScopeRepository();
  final _local = LocalJsonCache();
  static final Map<String, List<LearningSubject>> _subjectsCache = {};
  static final Map<String, List<LearningChapter>> _chaptersCache = {};


  static void clearMemory() {
    _subjectsCache.clear();
    _chaptersCache.clear();
  }

  /// Invalidation temps reel : purge RAM des le namespace touche.
  static void evictKeys(CacheTargets t) {
    if (t.exact.any((k) => k.startsWith('learn:')) ||
        t.prefixes.any((p) => p.startsWith('learn:'))) {
      clearMemory();
    }
  }

  Future<bool> hasSubjectsCacheForCourses() async {
    final scope = await _scopeRepo.current();
    if (scope == null || !scope.hasSeries) return false;
    return _local.hasKey(
      'learn:subjects:course:${scope.levelId}:${scope.seriesId}',
    );
  }

  Future<bool> hasChaptersCache(String subjectId) async {
    final scope = await _scopeRepo.current();
    if (scope == null || !scope.hasSeries) return false;
    return _local.hasKey(
      'learn:chapters:${scope.levelId}:${scope.seriesId}:$subjectId',
    );
  }

  List<LearningChapter>? peekChaptersForSubject(String subjectId) {
    for (final e in _chaptersCache.entries) {
      if (e.key.endsWith(':$subjectId')) return e.value;
    }
    return null;
  }

  Future<List<LearningSubject>> subjectsForCourses() async {
    final scope = await _scopeRepo.current();
    if (scope == null || !scope.hasSeries) return const [];
    final cacheKey = 'course:${scope.levelId}:${scope.seriesId}';
    final key = 'learn:subjects:$cacheKey';
    final cached = _subjectsCache[cacheKey];
    // Un cache VIDE peut dater d'avant l'ajout du contenu : on le traite comme un
    // cache-miss pour laisser le refetch reussir des que des matieres existent.
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    final localRows = await _local.readList(key);
    if (localRows != null && localRows.isNotEmpty) {
      final out = _subjectsFromRows(localRows);
      _subjectsCache[cacheKey] = out;
      return out;
    }
    if (!Env.hasSupabase) return const [];
    return await _refreshSubjects(scope.levelId, scope.seriesId!, cacheKey) ??
        const [];
  }

  Future<List<LearningChapter>> chaptersBySubject(String subjectId) async {
    final scope = await _scopeRepo.current();
    if (scope == null || !scope.hasSeries) return const [];
    final cacheKey = '${scope.levelId}:${scope.seriesId}:$subjectId';
    final key = 'learn:chapters:$cacheKey';
    final cached = _chaptersCache[cacheKey];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    final localRows = await _local.readList(key);
    if (localRows != null && localRows.isNotEmpty) {
      final out = localRows
          .map(
            (r) => LearningChapter(
              id: '${r['id']}',
              title: '${r['title']}',
              position: r['position'] as int? ?? 0,
              masteryPercent: r['mastery_percent'] as int?,
            ),
          )
          .toList();
      _chaptersCache[cacheKey] = out;
      return out;
    }
    if (!Env.hasSupabase) return const [];
    return await _refreshChapters(
          scope.levelId,
          scope.seriesId!,
          subjectId,
          cacheKey,
        ) ??
        const [];
  }

  /// Chapitres recommandés à partir du signal déclaratif de profil
  /// (`profile_subject_signals` — collecté à l'inscription, jamais exploité
  /// avant cette fonctionnalité). Retourne une liste vide si l'élève n'a
  /// aucun signal déclaratif : pas de section vide dans le feed, jamais de
  /// contenu générique déguisé en "recommandé".
  Future<List<({String chapterId, String subjectId, String title})>>
      fetchRecommendedChapters({int limit = 5}) async {
    if (!Env.hasSupabase) return const [];
    try {
      final rows = await Supabase.instance.client.rpc(
        'recommend_chapters_for_profile',
        params: {'p_limit': limit},
      );
      return (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map(
            (e) => (
              chapterId: '${e['chapter_id']}',
              subjectId: '${e['subject_id']}',
              title: '${e['title']}',
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<LearningSubject>?> _refreshSubjects(
    String levelId,
    String seriesId,
    String cacheKey,
  ) async {
    try {
      final rows = await Supabase.instance.client.rpc(
        'list_learning_subjects',
        params: {'p_level_id': levelId, 'p_series_id': seriesId},
      );
      final out = _subjectsFromRows(
        (rows as List).map((e) => Map<String, dynamic>.from(e as Map)).toList(),
      );
      _subjectsCache[cacheKey] = out;
      await _local.writeList(
        'learn:subjects:$cacheKey',
        out
            .map(
              (e) => {
                'id': e.id,
                'code': e.code,
                'label': e.label,
                'available_chapter_count': e.availableChapterCount,
              },
            )
            .toList(),
      );
      return out;
    } catch (_) {
      return null;
    }
  }

  Future<List<LearningChapter>?> _refreshChapters(
    String levelId,
    String seriesId,
    String subjectId,
    String cacheKey,
  ) async {
    try {
      final rows = await Supabase.instance.client.rpc(
        'list_chapters_with_mastery',
        params: {
          'p_level_id': levelId,
          'p_series_id': seriesId,
          'p_subject_id': subjectId,
        },
      );
      final out = (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map(
            (r) => LearningChapter(
              id: '${r['id']}',
              title: '${r['title']}',
              position: r['chapter_position'] as int? ?? 0,
              masteryPercent: r['mastery_percent'] as int?,
            ),
          )
          .toList();
      _chaptersCache[cacheKey] = out;
      await _local.writeList(
        'learn:chapters:$cacheKey',
        out
            .map((e) => {
                  'id': e.id,
                  'title': e.title,
                  'position': e.position,
                  'mastery_percent': e.masteryPercent,
                })
            .toList(),
      );
      return out;
    } catch (_) {
      return null;
    }
  }

  List<LearningSubject> _subjectsFromRows(List<Map<String, dynamic>> rows) {
    return rows.map((row) {
      return LearningSubject(
        id: '${row['id']}',
        code: '${row['code']}',
        label: '${row['label']}',
        availableChapterCount:
            (row['available_chapter_count'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }
}
