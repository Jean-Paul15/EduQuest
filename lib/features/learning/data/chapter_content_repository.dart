import 'dart:async';
import 'package:eduquest/features/learning/data/learning_scope_repository.dart';
import 'package:eduquest/features/learning/domain/chapter_resource.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/data/storage_url_resolver.dart';
import 'package:eduquest/shared/realtime/cache_signal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChapterContentRepository {
  final _scopeRepo = LearningScopeRepository();
  final _local = LocalJsonCache();
  static final Map<String, List<ChapterResource>> _resMem = {};
  static final Map<String, List<QuizSummary>> _quizMem = {};


  static void clearMemory() {
    _resMem.clear();
    _quizMem.clear();
  }

  /// Purge ciblee des Map RAM pour les cles invalidees par le temps reel
  /// (le `LocalJsonCache` seul ne suffit pas, `_resMem`/`_quizMem` survivent).
  static void evictKeys(CacheTargets t) {
    for (final k in t.exact) {
      _resMem.remove(k);
      _quizMem.remove(k);
    }
    for (final p in t.prefixes) {
      _resMem.removeWhere((k, _) => k.startsWith(p));
      _quizMem.removeWhere((k, _) => k.startsWith(p));
    }
  }

  Future<bool> hasResourcesCache({
    required String chapterId,
    required String type,
  }) async {
    final scope = await _scopeRepo.current();
    if (scope == null || !scope.hasSeries) return false;
    return _local.hasKey('chapter:res:${scope.seriesId}:$chapterId:$type');
  }

  Future<bool> hasQuizCache(String chapterId) async {
    final scope = await _scopeRepo.current();
    if (scope == null || !scope.hasSeries) return false;
    return _local.hasKey('chapter:qcm:${scope.seriesId}:$chapterId');
  }

  List<ChapterResource>? peekResources({
    required String chapterId,
    required String type,
  }) {
    for (final entry in _resMem.entries) {
      if (entry.key.endsWith(':$chapterId:$type')) return entry.value;
    }
    return null;
  }

  List<QuizSummary>? peekQuizzes(String chapterId) {
    for (final entry in _quizMem.entries) {
      if (entry.key.endsWith(':$chapterId')) return entry.value;
    }
    return null;
  }

  Future<List<ChapterResource>> resources({
    required String chapterId,
    required String type,
  }) async {
    final scope = await _scopeRepo.current();
    if (scope == null || !scope.hasSeries) return const [];
    final key = 'chapter:res:${scope.seriesId}:$chapterId:$type';
    final mem = _resMem[key];
    if (mem != null) {
      return mem;
    }
    final local = await _resourcesFromLocal(key);
    if (local.isNotEmpty) {
      _resMem[key] = local;
    }
    if (!Env.hasSupabase) return local;
    if (local.isNotEmpty) {
      return local;
    }
    return (await _refreshResources(
          chapterId: chapterId,
          type: type,
          key: key,
          seriesId: scope.seriesId!,
        )) ??
        local;
  }

  Future<List<QuizSummary>> quizzes(String chapterId) async {
    final scope = await _scopeRepo.current();
    if (scope == null || !scope.hasSeries) return const [];
    final key = 'chapter:qcm:${scope.seriesId}:$chapterId';
    final mem = _quizMem[key];
    if (mem != null) {
      return mem;
    }
    final local = await _quizFromLocal(key);
    if (local.isNotEmpty) {
      _quizMem[key] = local;
    }
    if (!Env.hasSupabase) return local;
    if (local.isNotEmpty) {
      return local;
    }
    return (await _refreshQuizzes(
          chapterId: chapterId,
          key: key,
          seriesId: scope.seriesId!,
        )) ??
        local;
  }

  Future<List<ChapterResource>?> _refreshResources({
    required String chapterId,
    required String type,
    required String key,
    required String seriesId,
  }) async {
    try {
      final rows = await Supabase.instance.client.rpc(
        'list_resources_for_chapter',
        params: {'p_chapter_id': chapterId, 'p_series_id': seriesId},
      );
      final out = (rows as List)
          .map((e) {
            final r = Map<String, dynamic>.from(e as Map);
            if ('${r['type']}' != type) return null;
            final url =
                r['external_url']?.toString() ??
                resolveContentUrl(r['storage_path']?.toString()) ??
                '';
            return ChapterResource(
              id: '${r['id']}',
              title: '${r['title']}',
              url: url,
            );
          })
          .whereType<ChapterResource>()
          .where((e) => e.url.isNotEmpty)
          .toList();
      _resMem[key] = out;
      await _local.writeList(
        key,
        out.map((e) => {'id': e.id, 'title': e.title, 'url': e.url}).toList(),
      );
      return out;
    } catch (_) {
      return null;
    }
  }

  Future<List<QuizSummary>?> _refreshQuizzes({
    required String chapterId,
    required String key,
    required String seriesId,
  }) async {
    try {
      final rows = await Supabase.instance.client.rpc(
        'list_quizzes_for_chapter',
        params: {'p_chapter_id': chapterId, 'p_series_id': seriesId},
      );
      final out = (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map((r) => QuizSummary(id: '${r['id']}', title: '${r['title']}'))
          .toList();
      _quizMem[key] = out;
      await _local.writeList(
        key,
        out.map((e) => {'id': e.id, 'title': e.title}).toList(),
      );
      return out;
    } catch (_) {
      return null;
    }
  }

  Future<List<ChapterResource>> _resourcesFromLocal(String key) async {
    final rows = await _local.readList(key);
    if (rows == null) return const [];
    return rows
        .map(
          (e) => ChapterResource(
            id: '${e['id']}',
            title: '${e['title']}',
            url: '${e['url']}',
          ),
        )
        .toList();
  }

  Future<List<QuizSummary>> _quizFromLocal(String key) async {
    final rows = await _local.readList(key);
    if (rows == null) return const [];
    return rows
        .map((e) => QuizSummary(id: '${e['id']}', title: '${e['title']}'))
        .toList();
  }
}
