import 'package:eduquest/shared/sync/service_locator.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Enregistre les tentatives de quiz côté serveur pour le socle de collecte
/// de données (progression, futurs signaux ML). Ne bloque jamais la fin d'un
/// quiz : essai direct pour un retour rapide si en ligne, sinon mise en file
/// dans la sync_queue offline-first (retry/backoff déjà gérés par
/// SyncService) au lieu de perdre silencieusement la tentative.
class QuizAttemptsRepository {
  Future<void> record(QuizResult result, String quizId) async {
    final payload = {
      'p_quiz_id': quizId,
      'p_result': {
        'score_percent': result.scorePercent,
        'passed': result.passed,
        'correct_count': result.correctCount,
        'wrong_count': result.wrongCount,
        'skipped_count': result.skippedCount,
        'total_questions': result.totalQuestions,
        'total_time_seconds': result.totalTimeSeconds,
        // Consommé par record_quiz_attempt (mig 222) pour semer un squelette
        // de méprise par question ratée — pas de classification IA ici,
        // juste de quoi alimenter "Pour toi" sans latence.
        'per_question': result.perQuestion
            .map((q) => {
                  'question_id': q.questionId,
                  'correct': q.correct,
                  'user_answer': q.userAnswer,
                  'correct_answer': q.correctAnswer,
                })
            .toList(),
      },
    };
    try {
      await Supabase.instance.client.rpc('record_quiz_attempt', params: payload);
      // La mise à jour de la maîtrise déclenche son propre Broadcast prive
      // (mig 221e, canal `learn:progress:<uid>`) : le cache se rafraîchit tout
      // seul via ContentRealtimeService, pas besoin d'invalider ici.
    } catch (_) {
      // Le résultat local (LocalQuizResultRepository) reste la source de
      // vérité offline ; la tentative est rejouée au retour de connexion.
      await ServiceLocator().sync.enqueueAndTryFlush(
        operation: 'RPC',
        targetTable: 'record_quiz_attempt',
        payload: payload,
      );
    }
  }
}
