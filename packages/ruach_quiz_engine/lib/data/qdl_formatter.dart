import '../domain/quiz_definition.dart';
import '../domain/quiz_question.dart';
import '../domain/quiz_session_config.dart';
import '../domain/quiz_group.dart';
import '../domain/quiz_content_block.dart';

/// Formate une [QuizDefinition] en JSON QDL pour stockage local.
class QdlFormatter {
  const QdlFormatter();

  Map<String, dynamic> toJson(QuizDefinition quiz) {
    final out = <String, dynamic>{
      'version': 2,
      'quiz': {
        'id': quiz.id,
        'title': quiz.title,
        'config': _config(quiz.config),
        'questions': quiz.questions.map(_question).toList(),
      },
    };
    if (quiz.groups.isNotEmpty) {
      out['quiz']['groups'] = quiz.groups.map(_group).toList();
    }
    if (quiz.questionsPool.isNotEmpty) {
      out['quiz']['questions_pool'] =
          quiz.questionsPool.map(_question).toList();
    }
    return out;
  }

  Map<String, dynamic> _config(QuizSessionConfig c) => {
    'mode': switch (c.mode) {
      QuizMode.orientation => 'orientation',
      QuizMode.adaptive => 'adaptive',
      QuizMode.standard => 'standard',
    },
    'time_per_question_seconds': c.timePerQuestionSeconds,
    'shuffle_options': c.shuffleOptions,
    'show_feedback': c.showFeedback,
    'allow_go_back': c.allowGoBack,
    'passing_score_percent': c.passingScorePercent,
    if (c.questionsPerSession != null)
      'questions_per_session': c.questionsPerSession,
    'pool_selection': c.poolSelection == PoolSelection.stratified
        ? 'stratified'
        : 'random',
    'no_repeat_in_session': c.noRepeatInSession,
  };

  Map<String, dynamic> _question(QuizQuestion q) => {
    'id': q.id,
    'type': _typeStr(q.type),
    'prompt': q.prompt,
    'answer_key': q.answerKey,
    if (q.statement.isNotEmpty) 'statement': q.statement.map(_block).toList(),
    if (q.mediaAbove != null) 'media_above': _block(q.mediaAbove!),
    if (q.explanation.isNotEmpty)
      'explanation': q.explanation.map(_block).toList(),
    if (q.context != null) 'context': q.context,
    if (q.groupId != null) 'group_id': q.groupId,
    'points': q.points,
    if (q.difficultyLevel != null) 'difficulty_level': q.difficultyLevel,
  };

  Map<String, dynamic> _group(QuestionGroup g) => {
    'id': g.id,
    if (g.title != null) 'group_title': g.title,
    if (g.sharedContext.isNotEmpty)
      'shared_context': g.sharedContext.map(_block).toList(),
    if (g.sharedMedia != null) 'shared_media': _block(g.sharedMedia!),
    'layout': g.layout == GroupLayout.allVisible ? 'all_visible' : 'sequential',
  };

  Map<String, dynamic> _block(ContentBlock b) => switch (b) {
    TextBlock(value: final val, style: final s) => {
      'type': 'text',
      'value': val,
      'style': s.name,
    },
    CalloutBlock(:final content, :final variant) => {
      'type': 'callout',
      'content': content.map(_block).toList(),
      'variant': variant.name,
    },
    LatexBlock(formula: final f, semanticLabel: final l, display: final d) => {
      'type': d ? 'latex_display' : 'latex_inline',
      'formula': f,
      'semantic_label': l,
    },
    ImageBlock(url: final u, alt: final a, caption: final c) => {
      'type': 'image',
      'url': u,
      'alt': a,
      if (c != null) 'caption': c,
    },
    CodeBlock(language: final l, value: final v) => {
      'type': 'code',
      'language': l,
      'value': v,
    },
    TableBlock(:final headers, :final rows, :final caption) => {
      'type': 'table',
      'headers': headers.map(_block).toList(),
      'rows': rows.map((r) => r.map(_block).toList()).toList(),
      if (caption != null) 'caption': caption,
    },
    AudioBlock(
      :final url,
      :final durationSeconds,
      :final transcript,
      :final autoPlay,
    ) =>
      {
        'type': 'audio',
        'url': url,
        if (durationSeconds != null) 'duration_seconds': durationSeconds,
        if (transcript != null) 'transcript': transcript,
        'auto_play': autoPlay,
      },
  };

  String _typeStr(QuestionType t) => switch (t) {
    QuestionType.singleChoice => 'single_choice',
    QuestionType.multiChoice => 'multi_choice',
    QuestionType.trueFalse => 'true_false',
    QuestionType.scale => 'scale',
    QuestionType.fillBlank => 'fill_blank',
    QuestionType.fillBlanks => 'fill_blanks',
    QuestionType.cloze => 'cloze',
    QuestionType.matching => 'matching',
    QuestionType.shortAnswer => 'short_answer',
  };
}
