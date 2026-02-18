import 'dart:async';
import 'package:eduquest/features/learning/data/learning_scope_repository.dart';
import 'package:eduquest/features/learning/domain/learning_chapter.dart';
import 'package:eduquest/features/learning/domain/learning_subject.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LearningCatalogRepository {
  final _scopeRepo = LearningScopeRepository();
  final _local = LocalJsonCache();
  static final Map<String, List<LearningSubject>> _subjectsCache = {};
  static final Map<String, List<LearningChapter>> _chaptersCache = {};

  static void clearMemory() {
    _subjectsCache.clear();
    _chaptersCache.clear();
  }

  Future<bool> hasSubjectsCacheForCourses() async {
    final scope = await _scopeRepo.current();
    if (scope == null) return false;
    return _local.hasKey('learn:subjects:course:${scope.levelId}');
  }

  Future<bool> hasChaptersCache(String subjectId) async {
    final scope = await _scopeRepo.current();
    if (scope == null) return false;
    return _local.hasKey('learn:chapters:${scope.levelId}:$subjectId');
  }

  List<LearningChapter>? peekChaptersForSubject(String subjectId) {
    for (final e in _chaptersCache.entries) {
      if (e.key.endsWith(':$subjectId')) return e.value;
    }
    return null;
  }

  Future<List<LearningSubject>> subjectsForCourses() async {
    final scope = await _scopeRepo.current();
    if (scope == null) return const [];
    final cacheKey = 'course:${scope.levelId}';
    final cached = _subjectsCache[cacheKey];
    if (cached != null) {
      if (Env.hasSupabase) {
        unawaited(_refreshSubjects(scope.levelId, cacheKey));
      }
      return cached;
    }
    final key = 'learn:subjects:$cacheKey';
    final localRows = await _local.readList(key);
    if (localRows != null) {
      final out = _subjectsFromRows(localRows);
      _subjectsCache[cacheKey] = out;
      if (Env.hasSupabase) {
        unawaited(_refreshSubjects(scope.levelId, cacheKey));
      }
      return out;
    }
    if (!Env.hasSupabase) return const [];
    return await _refreshSubjects(scope.levelId, cacheKey) ?? const [];
  }

  Future<List<LearningChapter>> chaptersBySubject(String subjectId) async {
    final scope = await _scopeRepo.current();
    if (scope == null) return const [];
    final cacheKey = '${scope.levelId}:$subjectId';
    final cached = _chaptersCache[cacheKey];
    if (cached != null) {
      if (Env.hasSupabase) {
        unawaited(_refreshChapters(scope.levelId, subjectId, cacheKey));
      }
      return cached;
    }
    final key = 'learn:chapters:$cacheKey';
    final localRows = await _local.readList(key);
    if (localRows != null) {
      final out = localRows
          .map(
            (r) => LearningChapter(
              id: '${r['id']}',
              title: '${r['title']}',
              position: r['position'] as int? ?? 0,
            ),
          )
          .toList();
      _chaptersCache[cacheKey] = out;
      if (Env.hasSupabase) {
        unawaited(_refreshChapters(scope.levelId, subjectId, cacheKey));
      }
      return out;
    }
    if (!Env.hasSupabase) return const [];
    return await _refreshChapters(scope.levelId, subjectId, cacheKey) ??
        const [];
  }

  Future<List<LearningSubject>?> _refreshSubjects(
    String levelId,
    String cacheKey,
  ) async {
    try {
      final rows = await Supabase.instance.client
          .from('chapters')
          .select('subject_id')
          .eq('education_level_id', levelId);
      final ids = (rows as List)
          .map((e) => '${(e as Map)['subject_id']}')
          .toSet()
          .toList();
      final out = await _loadSubjects(ids);
      _subjectsCache[cacheKey] = out;
      await _local.writeList(
        'learn:subjects:$cacheKey',
        out.map((e) => {'id': e.id, 'code': e.code, 'label': e.label}).toList(),
      );
      return out;
    } catch (_) {
      return null;
    }
  }

  Future<List<LearningChapter>?> _refreshChapters(
    String levelId,
    String subjectId,
    String cacheKey,
  ) async {
    try {
      final rows = await Supabase.instance.client
          .from('chapters')
          .select('id,title,position')
          .eq('education_level_id', levelId)
          .eq('subject_id', subjectId)
          .order('position');
      final out = (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map(
            (r) => LearningChapter(
              id: '${r['id']}',
              title: '${r['title']}',
              position: r['position'] as int? ?? 0,
            ),
          )
          .toList();
      _chaptersCache[cacheKey] = out;
      await _local.writeList(
        'learn:chapters:$cacheKey',
        out
            .map((e) => {'id': e.id, 'title': e.title, 'position': e.position})
            .toList(),
      );
      return out;
    } catch (_) {
      return null;
    }
  }

  Future<List<LearningSubject>> _loadSubjects(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final rows = await Supabase.instance.client
        .from('subjects')
        .select('id,code,label')
        .inFilter('id', ids)
        .order('label');
    return _subjectsFromRows(
      (rows as List).map((e) => Map<String, dynamic>.from(e as Map)).toList(),
    );
  }

  List<LearningSubject> _subjectsFromRows(List<Map<String, dynamic>> rows) {
    return rows.map((row) {
      return LearningSubject(
        id: '${row['id']}',
        code: '${row['code']}',
        label: '${row['label']}',
      );
    }).toList();
  }
}
