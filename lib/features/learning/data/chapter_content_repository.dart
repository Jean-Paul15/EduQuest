import 'dart:async';
import 'package:eduquest/features/learning/domain/chapter_resource.dart';
import 'package:eduquest/features/learning/domain/learning_quiz.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/cache_policy.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChapterContentRepository {
  final _local = LocalJsonCache();
  static final Map<String, List<ChapterResource>> _resMem = {};
  static final Map<String, List<LearningQuiz>> _quizMem = {};

  static void clearMemory() {
    _resMem.clear();
    _quizMem.clear();
  }

  Future<bool> hasResourcesCache({
    required String chapterId,
    required String type,
  }) {
    return _local.hasKey('chapter:res:$chapterId:$type');
  }

  Future<bool> hasQuizCache(String chapterId) {
    return _local.hasKey('chapter:qcm:$chapterId');
  }

  List<ChapterResource>? peekResources({
    required String chapterId,
    required String type,
  }) {
    return _resMem['chapter:res:$chapterId:$type'];
  }

  List<LearningQuiz>? peekQuizzes(String chapterId) {
    return _quizMem['chapter:qcm:$chapterId'];
  }

  Future<List<ChapterResource>> resources({
    required String chapterId,
    required String type,
  }) async {
    final key = 'chapter:res:$chapterId:$type';
    final mem = _resMem[key];
    if (mem != null) {
      if (Env.hasSupabase &&
          !await _local.isFresh(key, CachePolicy.chapterResources)) {
        unawaited(
          _refreshResources(chapterId: chapterId, type: type, key: key),
        );
      }
      return mem;
    }
    final local = await _resourcesFromLocal(key);
    if (local.isNotEmpty) {
      _resMem[key] = local;
    }
    if (!Env.hasSupabase) return local;
    if (local.isNotEmpty) {
      if (!await _local.isFresh(key, CachePolicy.chapterResources)) {
        unawaited(
          _refreshResources(chapterId: chapterId, type: type, key: key),
        );
      }
      return local;
    }
    return (await _refreshResources(
          chapterId: chapterId,
          type: type,
          key: key,
        )) ??
        local;
  }

  Future<List<LearningQuiz>> quizzes(String chapterId) async {
    final key = 'chapter:qcm:$chapterId';
    final mem = _quizMem[key];
    if (mem != null) {
      if (Env.hasSupabase &&
          !await _local.isFresh(key, CachePolicy.chapterQuizzes)) {
        unawaited(_refreshQuizzes(chapterId: chapterId, key: key));
      }
      return mem;
    }
    final local = await _quizFromLocal(key);
    if (local.isNotEmpty) {
      _quizMem[key] = local;
    }
    if (!Env.hasSupabase) return local;
    if (local.isNotEmpty) {
      if (!await _local.isFresh(key, CachePolicy.chapterQuizzes)) {
        unawaited(_refreshQuizzes(chapterId: chapterId, key: key));
      }
      return local;
    }
    return (await _refreshQuizzes(chapterId: chapterId, key: key)) ?? local;
  }

  Future<List<ChapterResource>?> _refreshResources({
    required String chapterId,
    required String type,
    required String key,
  }) async {
    try {
      final rows = await Supabase.instance.client
          .from('resources')
          .select('id,title,external_url,storage_path')
          .eq('chapter_id', chapterId)
          .eq('type', type)
          .eq('published', true)
          .order('title');
      final out = (rows as List)
          .map((e) {
            final r = Map<String, dynamic>.from(e as Map);
            final url =
                r['external_url']?.toString() ??
                r['storage_path']?.toString() ??
                '';
            return ChapterResource(
              id: '${r['id']}',
              title: '${r['title']}',
              url: url,
            );
          })
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

  Future<List<LearningQuiz>?> _refreshQuizzes({
    required String chapterId,
    required String key,
  }) async {
    try {
      final rows = await Supabase.instance.client
          .from('quizzes')
          .select('id,title')
          .eq('chapter_id', chapterId)
          .eq('published', true)
          .order('title');
      final out = (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map((r) => LearningQuiz(id: '${r['id']}', title: '${r['title']}'))
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

  Future<List<LearningQuiz>> _quizFromLocal(String key) async {
    final rows = await _local.readList(key);
    if (rows == null) return const [];
    return rows
        .map((e) => LearningQuiz(id: '${e['id']}', title: '${e['title']}'))
        .toList();
  }
}
