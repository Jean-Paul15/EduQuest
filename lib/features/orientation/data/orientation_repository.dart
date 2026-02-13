import 'dart:async';
import 'package:eduquest/features/surveys/data/survey_repository.dart';
import 'package:eduquest/features/surveys/domain/survey_question.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/cache_policy.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrientationRepository {
  final _surveys = SurveyRepository();
  final _local = LocalJsonCache();
  static (String, List<SurveyQuestion>)? _mem;

  Future<(String, List<SurveyQuestion>)?> activeQuestionnaire() async {
    final mem = _mem;
    if (mem != null) {
      if (Env.hasSupabase &&
          !await _local.isFresh(
            'orientation:active',
            CachePolicy.orientationQuestionnaire,
          )) {
        unawaited(_refresh());
      }
      return mem;
    }
    final local = await _fromLocal();
    if (local != null) {
      _mem = local;
      if (Env.hasSupabase &&
          !await _local.isFresh(
            'orientation:active',
            CachePolicy.orientationQuestionnaire,
          )) {
        unawaited(_refresh());
      }
      return local;
    }
    if (!Env.hasSupabase) return null;
    return await _refresh();
  }

  Future<(String, List<SurveyQuestion>)?> _refresh() async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final row = await Supabase.instance.client
          .from('surveys')
          .select('id,title')
          .ilike('title', '%orientation%')
          .lte('starts_at', now)
          .gte('ends_at', now)
          .order('starts_at')
          .limit(1)
          .maybeSingle();
      final id = row?['id']?.toString();
      if (id == null) return null;
      final q = await _surveys.questions(id);
      await _local.writeList('orientation:active', [
        {
          'id': id,
          'questions': q
              .map(
                (e) => {
                  'id': e.id,
                  'prompt': e.prompt,
                  'type': e.type,
                  'options': e.options,
                },
              )
              .toList(),
        },
      ]);
      _mem = (id, q);
      return (id, q);
    } catch (_) {
      return null;
    }
  }

  Future<String> submitAnswer({
    required String questionId,
    required String questionType,
    required String answer,
  }) {
    final opt = questionType == 'mcq' ? answer : null;
    final txt = questionType == 'text' ? answer : answer;
    return _surveys.submit(questionId: questionId, text: txt, option: opt);
  }

  Future<(String, List<SurveyQuestion>)?> _fromLocal() async {
    final rows = await _local.readList('orientation:active');
    if (rows == null || rows.isEmpty) return null;
    final x = rows.first;
    final id = '${x['id'] ?? ''}';
    final q = ((x['questions'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map((e) {
          final opts =
              (e['options'] as List?)?.map((v) => '$v').toList() ??
              const <String>[];
          return SurveyQuestion(
            id: '${e['id']}',
            prompt: '${e['prompt']}',
            type: '${e['type']}',
            options: opts,
          );
        })
        .toList();
    final out = id.isEmpty ? null : (id, q);
    if (out != null) _mem = out;
    return out;
  }
}
