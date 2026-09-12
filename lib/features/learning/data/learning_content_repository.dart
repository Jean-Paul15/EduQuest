import 'dart:async';
import 'package:eduquest/features/learning/domain/learning_item.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/data/storage_url_resolver.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eduquest/shared/realtime/cache_signal.dart';

typedef QuizBundle = ({
  String id,
  String title,
  Map<String, dynamic>? config,
  List<Map<String, dynamic>> groups,
  List<Map<String, dynamic>> questions,
  List<Map<String, dynamic>> questionsPool,
});

class LearningContentRepository {
  final _local = LocalJsonCache();
  static final Map<String, QuizBundle> _quizBundleMem = {};

  static void evictKeys(CacheTargets t) {
    for (final k in t.exact) {
      final m = RegExp(r'learn:qcm:v2:[a-z]+:(.+)').firstMatch(k);
      if (m != null) _quizBundleMem.remove(m.group(1));
    }
  }


  // Prefixe `v2` (2026-08-27) : invalide tout bundle capturé localement
  // avant le correctif de classification questions/pool côté backend
  // (migration 184) — un appareil ayant mis en cache un bundle pendant la
  // fenêtre bogguée aurait sinon rejoué indéfiniment un quiz sans questions.

  QuizBundle? peekQuizBundle(String quizId) => _quizBundleMem[quizId];

  Future<bool> hasQuizBundleCache(String quizId) async {
    if (_quizBundleMem.containsKey(quizId)) return true;
    final checks = await Future.wait([
      _local.hasKey('learn:qcm:v2:bundle:$quizId'),
      _local.hasKey('learn:qcm:v2:q:$quizId'),
      _local.hasKey('learn:qcm:v2:config:$quizId'),
      _local.hasKey('learn:qcm:v2:groups:$quizId'),
      _local.hasKey('learn:qcm:v2:pool:$quizId'),
    ]);
    return checks.any((value) => value);
  }

  Future<void> warmQuizBundle(String quizId) async {
    await fetchQuizBundle(quizId);
  }

  Future<QuizBundle> fetchQuizBundle(String quizId) async {
    final empty = (
      id: quizId,
      title: '',
      config: null,
      groups: <Map<String, dynamic>>[],
      questions: <Map<String, dynamic>>[],
      questionsPool: <Map<String, dynamic>>[],
    );
    final mem = _quizBundleMem[quizId];
    if (mem != null) {
      return mem;
    }
    final local = await _quizBundleFromLocal(quizId);
    if (local != null) {
      _quizBundleMem[quizId] = local;
    }
    if (!Env.hasSupabase) return local ?? empty;
    if (local != null) {
      return local;
    }
    return (await _refreshQuizBundle(quizId)) ?? empty;
  }

  Future<QuizBundle?> _refreshQuizBundle(String quizId) async {
    try {
      final payload = await Supabase.instance.client.rpc(
        'get_quiz_bundle',
        params: {'p_quiz_id': quizId},
      );
      final data = payload is Map
          ? _decodeQuizBundlePayload(Map<String, dynamic>.from(payload))
          : await _refreshQuizBundleLegacy(quizId);
      if (data == null) return null;
      _quizBundleMem[quizId] = data;
      await Future.wait([
        _local.writeList('learn:qcm:v2:bundle:$quizId', [
          {
            'id': data.id,
            'title': data.title,
            'config': data.config,
            'groups': data.groups,
            'questions': data.questions,
            'questions_pool': data.questionsPool,
          },
        ]),
        _local.writeList('learn:qcm:v2:q:$quizId', data.questions),
        _local.writeList('learn:qcm:v2:pool:$quizId', data.questionsPool),
        _local.writeList('learn:qcm:v2:groups:$quizId', data.groups),
        if (data.config != null)
          _local.writeList('learn:qcm:v2:config:$quizId', [data.config!]),
      ]);
      return data;
    } catch (_) {
      return _refreshQuizBundleLegacy(quizId);
    }
  }

  Future<QuizBundle?> _refreshQuizBundleLegacy(String quizId) async {
    try {
      final row = await Supabase.instance.client
          .from('quizzes')
          .select(
            'id,title,config,'
            'quiz_questions('
            'id,type,prompt,statement,media_above,answer_key,'
            'explanation,points,context,group_id,created_at'
            '),'
            'question_groups('
            'id,title,shared_context,shared_media,layout,created_at'
            ')',
          )
          .eq('id', quizId)
          .eq('published', true)
          .single();
      return _mapQuizBundle(Map<String, dynamic>.from(row));
    } catch (_) {
      return null;
    }
  }

  Future<List<LearningItem>> listResourceType(String type) async {
    final key = 'learn:res:$type';
    final local = await _itemsFromLocal(key);
    if (!Env.hasSupabase) return local;
    if (local.isNotEmpty) {
      return local;
    }
    return (await _refreshResourceType(type, key)) ?? local;
  }

  Future<List<LearningItem>?> _refreshResourceType(String type, String key) async {
    try {
      final rows = await Supabase.instance.client.rpc(
        'list_my_series_resources',
        params: {
          'p_types': [type],
        },
      );
      final out = (rows as List).map((r) {
        final e = Map<String, dynamic>.from(r as Map);
        final u = e['external_url']?.toString() ??
            resolveContentUrl(e['storage_path']?.toString());
        return LearningItem(
          id: '${e['id']}',
          title: '${e['title']}',
          subtitle: '${e['chapter_title'] ?? 'Contenu'}',
          url: u,
        );
      }).toList();
      await _local.writeList(
        key,
        out
            .map(
              (e) => {
                'id': e.id,
                'title': e.title,
                'subtitle': e.subtitle,
                'url': e.url,
                'count': e.count,
              },
            )
            .toList(),
      );
      return out;
    } catch (_) {
      return null;
    }
  }

  /// Retourne les questions en format brut compatible avec [QdlParser].
  Future<List<Map<String, dynamic>>> questionsAsQdl(String quizId) async {
    return (await fetchQuizBundle(quizId)).questions;
  }

  /// Pool de questions pour un quiz en mode `adaptive` (vide sinon).
  Future<List<Map<String, dynamic>>> questionsPoolAsQdl(String quizId) async {
    return (await fetchQuizBundle(quizId)).questionsPool;
  }

  /// Récupère la config du quiz (timer, seuil, feedback, etc.) depuis la DB.
  Future<Map<String, dynamic>?> fetchQuizConfig(String quizId) async {
    return (await fetchQuizBundle(quizId)).config;
  }

  /// Récupère les groupes de questions (contexte partagé) depuis la DB.
  Future<List<Map<String, dynamic>>> fetchQuestionGroups(String quizId) async {
    return (await fetchQuizBundle(quizId)).groups;
  }

  Future<List<LearningItem>> _itemsFromLocal(String key) async {
    final rows = await _local.readList(key);
    if (rows == null) return const [];
    return rows
        .map(
          (e) => LearningItem(
            id: '${e['id']}',
            title: '${e['title']}',
            subtitle: '${e['subtitle']}',
            url: e['url']?.toString(),
            count: e['count'] as int?,
          ),
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> _qFromLocalRaw(String key) async {
    try {
      final rows = await _local.readList(key);
      if (rows == null) return [];
      return rows.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  QuizBundle _mapQuizBundle(Map<String, dynamic> row) {
    final rawQuestions =
        ((row['quiz_questions'] as List?) ?? const [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList()
          ..sort(
            (a, b) => '${a['created_at'] ?? ''}'.compareTo(
              '${b['created_at'] ?? ''}',
            ),
          );
    final rawGroups =
        ((row['question_groups'] as List?) ?? const [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList()
          ..sort(
            (a, b) => '${a['created_at'] ?? ''}'.compareTo(
              '${b['created_at'] ?? ''}',
            ),
          );
    final questions = rawQuestions.map((e) {
      final ak = e['answer_key'] is Map
          ? Map<String, dynamic>.from(e['answer_key'] as Map)
          : <String, dynamic>{};
      return {
        'id': '${e['id']}',
        'type': '${e['type'] ?? 'mcq'}',
        if (e['prompt'] != null) 'prompt': e['prompt'],
        if (e['statement'] != null) 'statement': e['statement'],
        if (e['media_above'] != null) 'media_above': e['media_above'],
        'answer_key': ak,
        if (e['explanation'] != null) 'explanation': e['explanation'],
        if (e['points'] != null) 'points': e['points'],
        if (e['context'] != null) 'context': e['context'],
        if (e['group_id'] != null) 'group_id': '${e['group_id']}',
      };
    }).toList();
    final groups = rawGroups.map((e) {
      return {
        'id': '${e['id']}',
        if (e['title'] != null) 'group_title': e['title'],
        if (e['shared_context'] != null) 'shared_context': e['shared_context'],
        if (e['shared_media'] != null) 'shared_media': e['shared_media'],
        'layout': '${e['layout'] ?? 'sequential'}',
      };
    }).toList();
    final config = row['config'] is Map
        ? Map<String, dynamic>.from(row['config'] as Map)
        : null;
    return (
      id: '${row['id'] ?? ''}',
      title: '${row['title'] ?? ''}',
      config: config,
      groups: groups,
      questions: questions,
      // Chemin legacy (fallback si get_quiz_bundle échoue) : pas de split
      // pool/liste fixe — les quiz adaptatifs se dégradent en liste fixe.
      questionsPool: const [],
    );
  }

  QuizBundle _decodeQuizBundlePayload(Map<String, dynamic> payload) {
    final groups = ((payload['groups'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final questions = ((payload['questions'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final questionsPool = ((payload['questions_pool'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final config = payload['config'] is Map
        ? Map<String, dynamic>.from(payload['config'] as Map)
        : null;
    return (
      id: '${payload['id'] ?? ''}',
      title: '${payload['title'] ?? ''}',
      config: config,
      groups: groups,
      questions: questions,
      questionsPool: questionsPool,
    );
  }

  Future<QuizBundle?> _quizBundleFromLocal(String quizId) async {
    try {
      final bundle = await _local.readList('learn:qcm:v2:bundle:$quizId');
      final row = bundle?.firstOrNull;
      if (row != null) {
        return (
          id: '${row['id'] ?? quizId}',
          title: '${row['title'] ?? ''}',
          config: row['config'] is Map
              ? Map<String, dynamic>.from(row['config'] as Map)
              : null,
          groups: ((row['groups'] as List?) ?? const [])
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList(),
          questions: ((row['questions'] as List?) ?? const [])
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList(),
          questionsPool: ((row['questions_pool'] as List?) ?? const [])
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList(),
        );
      }
    } catch (_) {}
    final results = await Future.wait([
      _qFromLocalRaw('learn:qcm:v2:q:$quizId'),
      _qFromLocalRaw('learn:qcm:v2:pool:$quizId'),
      _qFromLocalRaw('learn:qcm:v2:groups:$quizId'),
      _local.readList('learn:qcm:v2:config:$quizId'),
    ]);
    final questions = results[0] as List<Map<String, dynamic>>;
    final questionsPool = results[1] as List<Map<String, dynamic>>;
    final groups = results[2] as List<Map<String, dynamic>>;
    final config = results[3]?.firstOrNull?.cast<String, dynamic>();
    if (questions.isEmpty && questionsPool.isEmpty && groups.isEmpty && config == null) {
      return null;
    }
    return (
      id: quizId,
      title: '',
      config: config,
      groups: groups,
      questions: questions,
      questionsPool: questionsPool,
    );
  }
}
