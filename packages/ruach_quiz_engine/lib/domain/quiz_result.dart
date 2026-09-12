import 'quiz_session_config.dart';

/// Résultat d'un quiz terminé.
class QuizResult {
  const QuizResult({
    required this.mode,
    required this.totalQuestions,
    required this.totalPoints,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    required this.earnedPoints,
    required this.totalTimeSeconds,
    required this.perQuestion,
    required this.passingScorePercent,
    this.axisScores = const {},
  });

  final QuizMode mode;
  final int totalQuestions;
  final int totalPoints;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final double earnedPoints;
  final int totalTimeSeconds;
  final List<QuestionResult> perQuestion;
  final int passingScorePercent;
  final Map<String, double> axisScores;

  /// Score pondéré par les points (respecte partialCredit, penaltyPerWrong).
  double get scorePercent =>
      totalPoints == 0 ? 0 : (earnedPoints / totalPoints) * 100;

  /// Alias conservé pour rétrocompatibilité — même calcul que [scorePercent].
  double get pointsPercent => scorePercent;
  bool get passed => scorePercent >= passingScorePercent;
  List<String> get dominantAxes {
    final ranked = axisScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ranked.take(3).map((e) => e.key).toList(growable: false);
  }
}

/// Résultat pour une question individuelle.
class QuestionResult {
  const QuestionResult({
    required this.questionId,
    required this.correct,
    required this.pointsEarned,
    required this.timeSpentSeconds,
    required this.userAnswer,
    this.correctAnswer,
  });

  final String questionId;
  final bool correct;
  final double pointsEarned;
  final int timeSpentSeconds;
  final String? userAnswer;
  final String? correctAnswer;
}
