import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

/// Persiste les résultats de quiz localement pour consultation hors-ligne.
class LocalQuizResultRepository {
  final _local = LocalJsonCache();
  // Préfixe 'results:' (pas 'learn:') pour éviter suppression par le realtime sync
  static const _key = 'results:quiz';

  /// Sauvegarde un résultat de quiz avec horodatage.
  Future<void> save(QuizResult result, String quizId, String quizTitle) async {
    final rows = (await _local.readList(_key)) ?? [];
    rows.insert(0, {
      'quiz_id': quizId,
      'title': quizTitle,
      'score_percent': result.scorePercent,
      'passed': result.passed,
      'correct': result.correctCount,
      'wrong': result.wrongCount,
      'skipped': result.skippedCount,
      'total_questions': result.totalQuestions,
      'time_seconds': result.totalTimeSeconds,
      'completed_at': DateTime.now().toIso8601String(),
    });
    // Garde les 50 derniers résultats
    if (rows.length > 50) rows.length = 50;
    await _local.writeList(_key, rows);
  }

  /// Récupère l'historique des résultats locaux.
  Future<List<Map<String, dynamic>>> loadHistory() async =>
      (await _local.readList(_key)) ?? [];

  /// Vérifie si des résultats existent en local (utile pour badge offline).
  Future<bool> hasHistory() async {
    final rows = await _local.readList(_key);
    return rows != null && rows.isNotEmpty;
  }
}
