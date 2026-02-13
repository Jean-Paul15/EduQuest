import 'package:eduquest/features/learning/domain/learning_item.dart';
import 'package:eduquest/features/learning/domain/qcm_question.dart';
import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/features/videos/data/video_scope.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LearningContentRepository {
  final _local = LocalJsonCache();

  Future<List<LearningItem>> listResourceType(String type) async {
    if (!Env.hasSupabase) return _itemsFromLocal('learn:res:$type');
    final p = await UserProfileRepository().load();
    try {
      final rows = await Supabase.instance.client
          .from('resources')
          .select('id,title,access_scope,external_url,storage_path')
          .eq('type', type)
          .eq('published', true);
      final out = (rows as List)
          .where((r) {
            final s = Map<String, dynamic>.from(
              ((r as Map)['access_scope'] as Map?) ?? {},
            );
            return VideoScope.isVisible(
              scope: s,
              levelCode: p.levelCode,
              serieCode: p.serieCode,
            );
          })
          .map((r) {
            final e = Map<String, dynamic>.from(r as Map);
            final s = Map<String, dynamic>.from(
              (e['access_scope'] as Map?) ?? {},
            );
            final u =
                e['external_url']?.toString() ?? e['storage_path']?.toString();
            return LearningItem(
              id: '${e['id']}',
              title: '${e['title']}',
              subtitle: '${s['chapter'] ?? 'Contenu'}',
              url: u,
            );
          })
          .toList();
      await _local.writeList(
        'learn:res:$type',
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
      return _itemsFromLocal('learn:res:$type');
    }
  }

  Future<List<LearningItem>> listQuizzes() async {
    if (!Env.hasSupabase) return _itemsFromLocal('learn:qcm:list');
    try {
      final rows = await Supabase.instance.client
          .from('quizzes')
          .select('id,title');
      final result = <LearningItem>[];
      for (final r in rows as List) {
        final id = '${(r as Map)['id']}';
        final q = await Supabase.instance.client
            .from('quiz_questions')
            .select('id')
            .eq('quiz_id', id);
        result.add(
          LearningItem(
            id: id,
            title: '${r['title']}',
            subtitle: 'QCM dynamique',
            count: (q as List).length,
          ),
        );
      }
      await _local.writeList(
        'learn:qcm:list',
        result
            .map(
              (e) => {
                'id': e.id,
                'title': e.title,
                'subtitle': e.subtitle,
                'count': e.count,
                'url': e.url,
              },
            )
            .toList(),
      );
      return result;
    } catch (_) {
      return _itemsFromLocal('learn:qcm:list');
    }
  }

  Future<List<QcmQuestion>> questions(String quizId) async {
    if (!Env.hasSupabase) return _qFromLocal('learn:qcm:q:$quizId');
    try {
      final rows = await Supabase.instance.client
          .from('quiz_questions')
          .select('id,prompt,answer_key')
          .eq('quiz_id', quizId);
      final out = (rows as List)
          .map((r) {
            final e = Map<String, dynamic>.from(r as Map);
            final key = Map<String, dynamic>.from(
              (e['answer_key'] as Map?) ?? {},
            );
            final opts =
                (key['options'] as List?)?.map((x) => '$x').toList() ??
                const <String>[];
            return QcmQuestion(
              id: '${e['id']}',
              prompt: '${e['prompt']}',
              options: opts,
              answer: '${key['answer'] ?? ''}',
            );
          })
          .where((q) => q.options.isNotEmpty && q.answer.isNotEmpty)
          .toList();
      await _local.writeList(
        'learn:qcm:q:$quizId',
        out
            .map(
              (e) => {
                'id': e.id,
                'prompt': e.prompt,
                'options': e.options,
                'answer': e.answer,
              },
            )
            .toList(),
      );
      return out;
    } catch (_) {
      return _qFromLocal('learn:qcm:q:$quizId');
    }
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

  Future<List<QcmQuestion>> _qFromLocal(String key) async {
    final rows = await _local.readList(key);
    if (rows == null) return const [];
    return rows.map((e) {
      final opts =
          (e['options'] as List?)?.map((x) => '$x').toList() ??
          const <String>[];
      return QcmQuestion(
        id: '${e['id']}',
        prompt: '${e['prompt']}',
        options: opts,
        answer: '${e['answer']}',
      );
    }).toList();
  }
}
