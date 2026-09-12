import 'dart:math';
import '../domain/quiz_question.dart';
import '../domain/quiz_session_config.dart';
import '../domain/quiz_content_block.dart';
import 'content_block_parser.dart';

/// Fonctions helper pour le parsing QDL.
class QdlParserHelpers {
  static QuizQuestion parseQuestion(Map<String, dynamic> raw) {
    final typeStr = raw['type'] as String? ?? 'single_choice';
    final media = raw['media_above'];
    return QuizQuestion(
      id: raw['id'] as String,
      type: QuizQuestion.typeFromString(typeStr),
      statement: ContentBlockParser.parseList(raw['statement']),
      mediaAbove: media is Map
          ? ContentBlockParser.parse(Map<String, dynamic>.from(media))
          : null,
      prompt: raw['prompt'] as String? ?? '',
      answerKey:
          (raw['answer_key'] as Map?)?.map((k, v) => MapEntry('$k', v)) ?? {},
      explanation: ContentBlockParser.parseFlexibleList(raw['explanation']),
      points: raw['points'] as int? ?? 1,
      context: raw['context'] as String?,
      groupId: raw['group_id'] as String?,
      difficultyLevel: (raw['difficulty_level'] as num?)?.toDouble(),
    );
  }

  static QuizQuestion? parseLegacyQuestion(Map<String, dynamic> raw) {
    final typeStr = raw['type'] as String? ?? 'mcq';
    final key =
        (raw['answer_key'] as Map?)?.map((k, v) => MapEntry('$k', v)) ??
        <String, dynamic>{};
    final media = raw['media_above'];
    if (key.isEmpty && (typeStr == 'mcq' || typeStr == 'single_choice')) {
      final opts = (raw['options'] as List?)?.map((e) => '$e').toList() ?? [];
      final answer = raw['answer'] as String? ?? '';
      if (opts.isEmpty || answer.isEmpty) return null;
      return QuizQuestion(
        id: raw['id'] as String? ?? _generateId(),
        type: QuizQuestion.typeFromString(typeStr),
        statement: ContentBlockParser.parseList(raw['statement']),
        mediaAbove: media is Map
            ? ContentBlockParser.parse(Map<String, dynamic>.from(media))
            : null,
        prompt: raw['prompt'] as String? ?? '',
        answerKey: {'options': opts, 'answer': answer},
        explanation: ContentBlockParser.parseFlexibleList(raw['explanation']),
        points: raw['points'] as int? ?? 1,
        context: raw['context'] as String?,
        groupId: raw['group_id'] as String?,
        difficultyLevel: (raw['difficulty_level'] as num?)?.toDouble(),
      );
    }
    return QuizQuestion(
      id: raw['id'] as String? ?? _generateId(),
      type: QuizQuestion.typeFromString(typeStr),
      statement: ContentBlockParser.parseList(raw['statement']),
      mediaAbove: media is Map
          ? ContentBlockParser.parse(Map<String, dynamic>.from(media))
          : null,
      prompt: raw['prompt'] as String? ?? '',
      answerKey: key,
      explanation: ContentBlockParser.parseFlexibleList(raw['explanation']),
      points: raw['points'] as int? ?? 1,
      context: raw['context'] as String?,
      groupId: raw['group_id'] as String?,
      difficultyLevel: (raw['difficulty_level'] as num?)?.toDouble(),
    );
  }

  static QuizSessionConfig parseConfig(Map<String, dynamic>? json) {
    if (json == null) return const QuizSessionConfig();
    return QuizSessionConfig(
      mode: _parseMode(json['mode'] as String?),
      timePerQuestionSeconds: json['time_per_question_seconds'] as int? ?? 30,
      shuffleOptions: json['shuffle_options'] as bool? ?? true,
      showFeedback: json['show_feedback'] as bool? ?? true,
      allowGoBack: json['allow_go_back'] as bool? ?? false,
      passingScorePercent: json['passing_score_percent'] as int? ?? 50,
      feedbackMode: _parseFeedbackMode(json['feedback_mode'] as String?),
      showCorrectAnswer: json['show_correct_answer'] as bool? ?? true,
      showExplanation: json['show_explanation'] as bool? ?? true,
      allowSkip: json['allow_skip'] as bool? ?? true,
      editableUntilNext: json['editable_until_next'] as bool? ?? false,
      partialCredit: json['partial_credit'] as bool? ?? false,
      penaltyPerWrong: (json['penalty_per_wrong'] as num?)?.toDouble() ?? 0.0,
      questionsPerSession: json['questions_per_session'] as int?,
      poolSelection: json['pool_selection'] == 'stratified'
          ? PoolSelection.stratified
          : PoolSelection.random,
      noRepeatInSession: json['no_repeat_in_session'] as bool? ?? false,
    );
  }

  static QuizMode _parseMode(String? m) => switch (m) {
    'orientation' => QuizMode.orientation,
    'adaptive' => QuizMode.adaptive,
    _ => QuizMode.standard,
  };

  static FeedbackMode _parseFeedbackMode(String? m) => switch (m) {
    'after_submit' => FeedbackMode.afterSubmit,
    'never' || 'after_exam' => FeedbackMode.never,
    _ => FeedbackMode.immediate,
  };

  static String _generateId() {
    final r = Random();
    return List.generate(12, (_) => r.nextInt(16).toRadixString(16)).join();
  }
}
