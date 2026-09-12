import '../domain/quiz_answer.dart';
import '../domain/quiz_definition.dart';
import '../domain/quiz_question.dart';
import '../domain/quiz_result.dart';
import 'scoring_helpers.dart';

/// Moteur de scoring : attribue des points par question selon son type.
class ScoringEngine {
  const ScoringEngine();

  /// Calcule le résultat complet d'un quiz à partir des réponses.
  ///
  /// [playedQuestions] : les questions réellement jouées dans cette session —
  /// `quiz.questions` en mode standard, ou le sous-ensemble tiré du pool en
  /// mode `adaptive` (où `quiz.questions` est vide par construction).
  QuizResult score(
    QuizDefinition quiz,
    List<QuizQuestion> playedQuestions,
    Map<String, QuizAnswer> answers,
    Map<String, int> timeSpentPerQuestion,
  ) {
    final perQuestion = <QuestionResult>[];
    final axisScores = <String, double>{};
    var correctCount = 0, wrongCount = 0, skippedCount = 0;
    double earnedPoints = 0;
    var totalPoints = 0;

    for (final q in playedQuestions) {
      totalPoints += q.points;
      final answer = answers[q.id];
      final timeSpent = timeSpentPerQuestion[q.id] ?? 0;
      if (answer == null) {
        // Une question passée compte comme une mauvaise réponse pour le
        // score (0 point + pénalité éventuelle, comme une vraie erreur) —
        // `skippedCount` reste suivi séparément uniquement pour l'affichage
        // ("Passés" sur l'écran résultat), pas pour exempter la question de
        // la notation.
        skippedCount++;
        wrongCount++;
        earnedPoints -= q.points * quiz.config.penaltyPerWrong;
        perQuestion.add(
          QuestionResult(
            questionId: q.id,
            correct: false,
            pointsEarned: 0,
            timeSpentSeconds: timeSpent,
            userAnswer: null,
            correctAnswer: ScoringHelpers.correctAnswerString(q),
          ),
        );
        continue;
      }
      _accumulateAxisScores(q, answer, axisScores);
      final correct = ScoringHelpers.isCorrect(q, answer);
      final pts = ScoringHelpers.pointsEarned(
        q,
        answer,
        quiz.config.partialCredit,
      );
      if (correct) {
        correctCount++;
        earnedPoints += pts;
      } else {
        wrongCount++;
        earnedPoints += pts; // partial credit possible
        earnedPoints -= q.points * quiz.config.penaltyPerWrong;
      }
      perQuestion.add(
        QuestionResult(
          questionId: q.id,
          correct: correct,
          pointsEarned: pts,
          timeSpentSeconds: timeSpent,
          userAnswer: ScoringHelpers.userAnswerString(answer),
          correctAnswer: ScoringHelpers.correctAnswerString(q),
        ),
      );
    }

    return QuizResult(
      mode: quiz.config.mode,
      totalQuestions: playedQuestions.length,
      totalPoints: totalPoints,
      correctCount: correctCount,
      wrongCount: wrongCount,
      skippedCount: skippedCount,
      earnedPoints: earnedPoints,
      totalTimeSeconds: timeSpentPerQuestion.values.fold(0, (a, b) => a + b),
      perQuestion: perQuestion,
      passingScorePercent: quiz.config.passingScorePercent,
      axisScores: axisScores,
    );
  }

  void _accumulateAxisScores(
    QuizQuestion question,
    QuizAnswer answer,
    Map<String, double> axisScores,
  ) {
    final raw = question.answerKey['axis_scores'];
    if (raw is! Map) return;
    final maps = Map<String, dynamic>.from(raw);
    for (final entry in maps.entries) {
      final weights = entry.value is Map
          ? Map<String, dynamic>.from(entry.value as Map)
          : const <String, dynamic>{};
      final delta = _axisDelta(answer, weights);
      if (delta == 0) continue;
      axisScores[entry.key] = (axisScores[entry.key] ?? 0) + delta;
    }
  }

  double _axisDelta(QuizAnswer answer, Map<String, dynamic> weights) =>
      switch (answer) {
        ScaleAnswer(selected: final value) =>
          (weights['$value'] as num?)?.toDouble() ?? 0,
        SingleChoiceAnswer(selected: final value) =>
          (weights[value] as num?)?.toDouble() ?? 0,
        MultiChoiceAnswer(selected: final values) => values.fold<double>(
          0,
          (sum, value) => sum + ((weights[value] as num?)?.toDouble() ?? 0),
        ),
        _ => 0,
      };
}
