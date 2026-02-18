import 'dart:async';
import 'package:eduquest/features/surveys/domain/survey_question.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SurveyRepository {
  final _local = LocalJsonCache();

  Future<List<SurveyQuestion>> questions(String surveyId) async {
    final key = 'survey:q:$surveyId';
    final local = await _fromLocal(key);
    if (!Env.hasSupabase) return local;
    if (local.isNotEmpty) {
      unawaited(_refreshQuestions(surveyId: surveyId, key: key));
      return local;
    }
    return (await _refreshQuestions(surveyId: surveyId, key: key)) ?? local;
  }

  Future<String> submit({
    required String questionId,
    String? text,
    String? option,
  }) async {
    if (!Env.hasSupabase) return 'Supabase non configuré.';
    try {
      final json = option == null ? <String, dynamic>{} : {'selected': option};
      final res = await Supabase.instance.client.rpc(
        'submit_survey_answer',
        params: {
          'p_question_id': questionId,
          'p_answer_text': text,
          'p_answer_json': json,
        },
      );
      return Map<String, dynamic>.from(res as Map)['message']?.toString() ??
          'Réponse enregistrée.';
    } catch (_) {
      return 'Impossible d’enregistrer la réponse pour le moment.';
    }
  }

  Future<String> submitAll(List<Map<String, dynamic>> answers) async {
    if (!Env.hasSupabase) return 'Supabase non configuré.';
    if (answers.isEmpty) return 'Aucune réponse à envoyer.';
    try {
      final res = await Supabase.instance.client.rpc(
        'submit_survey_answers_bulk',
        params: {'p_answers': answers},
      );
      final out = Map<String, dynamic>.from(res as Map);
      return out['message']?.toString() ?? 'Réponses enregistrées.';
    } catch (_) {
      var ok = 0;
      for (final a in answers) {
        final msg = await submit(
          questionId: '${a['question_id']}',
          text: a['answer_text']?.toString(),
          option: (a['answer_json'] as Map?)?['selected']?.toString(),
        );
        final failed =
            msg.toLowerCase().contains('impossible') ||
            msg.toLowerCase().contains('non');
        if (failed) return 'Échec partiel: $ok/${answers.length} enregistrées.';
        ok++;
      }
      return 'Réponses enregistrées ($ok/${answers.length}).';
    }
  }

  Future<List<SurveyQuestion>> _fromLocal(String key) async {
    final rows = await _local.readList(key);
    if (rows == null) return const [];
    return rows.map((e) {
      final opts =
          (e['options'] as List?)?.map((x) => '$x').toList() ??
          const <String>[];
      return SurveyQuestion(
        id: '${e['id']}',
        prompt: '${e['prompt']}',
        type: '${e['type']}',
        options: opts,
      );
    }).toList();
  }

  Future<List<SurveyQuestion>?> _refreshQuestions({
    required String surveyId,
    required String key,
  }) async {
    try {
      final rows = await Supabase.instance.client
          .from('survey_questions')
          .select('id,prompt,question_type,options,position')
          .eq('survey_id', surveyId)
          .order('position');
      final out = (rows as List).map((e) {
        final opts =
            (e['options'] as List?)?.map((x) => '$x').toList() ??
            const <String>[];
        return SurveyQuestion(
          id: '${e['id']}',
          prompt: '${e['prompt']}',
          type: '${e['question_type']}',
          options: opts,
        );
      }).toList();
      await _local.writeList(
        key,
        out
            .map(
              (e) => {
                'id': e.id,
                'prompt': e.prompt,
                'type': e.type,
                'options': e.options,
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
