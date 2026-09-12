import 'dart:math' as math;

/// Estimation Elo-lite de l'habileté de l'élève : mise à jour localement
/// après chaque réponse, aucune dépendance ML, aucune donnée envoyée au
/// serveur. Base concrète de la « difficulté adaptative » du moteur
/// (RUACHEDU_QUIZ_ENGINE.md §12.3), qui était jusqu'ici une règle figée
/// (2 bonnes réponses de suite → niveau +1).
class EloLite {
  const EloLite({this.kFactor = 24});
  final double kFactor;

  static const defaultAbility = 1000.0;

  /// Probabilité que l'élève ([ability]) réussisse une question de
  /// difficulté [difficulty] — formule Elo standard.
  double expectedScore(double ability, double difficulty) =>
      1 / (1 + math.pow(10, (difficulty - ability) / 400));

  /// Nouvelle habileté après une réponse, bornée pour éviter toute dérive.
  double updateAbility(
    double ability,
    double difficulty,
    bool correct, {
    double minRating = 400,
    double maxRating = 2400,
  }) {
    final expected = expectedScore(ability, difficulty);
    final actual = correct ? 1.0 : 0.0;
    final next = ability + kFactor * (actual - expected);
    return next.clamp(minRating, maxRating);
  }

  /// Difficulté approximative d'une question à partir de son barème —
  /// proxy provisoire tant qu'un vrai champ `difficulty_level` (§8 du .md,
  /// pas encore modélisé dans `QuizQuestion`) n'existe pas dans le QDL.
  static double difficultyFromPoints(int points) =>
      1000 + (points.clamp(1, 10) - 1) * 80;
}
