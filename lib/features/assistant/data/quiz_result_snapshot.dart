import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

/// Aplatit `QuizResult` + `QuizDefinition` (déjà en mémoire à la fin d'un quiz
/// inline) en JSON compact pour l'edge function (P0-b détection de méprises) :
/// texte uniquement, jamais de média, pas d'arbre `ContentBlock`.
Map<String, dynamic> buildQuizResultSnapshot(
  QuizResult result,
  QuizDefinition definition,
) => {
  'perQuestion': result.perQuestion
      .map((q) => {
            'questionId': q.questionId,
            'correct': q.correct,
            'userAnswer': q.userAnswer,
            'correctAnswer': q.correctAnswer,
          })
      .toList(),
  'definitionSnapshot': {
    'questions': definition.questions
        .map((q) => {
              'id': q.id,
              'prompt': q.displayText,
              'answerKey': q.answerKey,
              'explanation': _flatten(q.explanation),
              'difficultyLevel': q.difficultyLevel,
            })
        .toList(),
  },
};

String _flatten(List<ContentBlock> blocks) {
  final parts = <String>[];
  for (final b in blocks) {
    switch (b) {
      case TextBlock(:final value):
        parts.add(value);
      case LatexBlock(:final formula):
        parts.add('\$$formula\$');
      case CalloutBlock(:final content):
        parts.add(_flatten(content));
      default:
        break;
    }
  }
  return parts.join(' ').trim();
}
