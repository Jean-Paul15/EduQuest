import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

/// Implémentation réelle de [QuizAnalyticsInterface] via Supabase.
class SupabaseQuizAnalytics implements QuizAnalyticsInterface {
  SupabaseQuizAnalytics();
  final _analytics = AppAnalytics();

  @override
  void trackQuizStarted(String quizId, String title, int totalQuestions) =>
      _analytics.track(
        'quiz_started',
        category: 'quiz',
        targetType: 'quiz',
        targetId: quizId,
        payload: {
          'quiz_id': quizId,
          'title': title,
          'total_questions': totalQuestions,
        },
      );

  @override
  void trackQuestionAnswered(
    String quizId,
    String questionId,
    QuestionType type,
    bool correct,
    int timeSeconds,
  ) => _analytics.track(
    'quiz_question_answered',
    category: 'quiz',
    targetType: 'quiz',
    targetId: quizId,
    payload: {
      'quiz_id': quizId,
      'question_id': questionId,
      'question_type': type.name,
      'correct': correct,
      'time_seconds': timeSeconds,
    },
  );

  @override
  void trackQuestionSkipped(String quizId, String questionId) =>
      _analytics.track(
        'quiz_question_skipped',
        category: 'quiz',
        targetType: 'quiz',
        targetId: quizId,
        payload: {'quiz_id': quizId, 'question_id': questionId},
      );

  @override
  void trackQuizCompleted(
    String quizId,
    double scorePercent,
    bool passed,
    int totalTimeSeconds,
    int correctCount,
    int totalQuestions,
  ) => _analytics.track(
    'quiz_completed',
    category: 'quiz',
    targetType: 'quiz',
    targetId: quizId,
    payload: {
      'quiz_id': quizId,
      'score_percent': scorePercent,
      'passed': passed,
      'total_time_seconds': totalTimeSeconds,
      'correct_count': correctCount,
      'total_questions': totalQuestions,
    },
  );

  @override
  void trackQuizAbandoned(
    String quizId,
    int questionIndex,
    int elapsedSeconds,
  ) => _analytics.track(
    'quiz_abandoned',
    category: 'quiz',
    targetType: 'quiz',
    targetId: quizId,
    payload: {
      'quiz_id': quizId,
      'question_index': questionIndex,
      'elapsed_seconds': elapsedSeconds,
    },
  );

  @override
  void trackImageLoadFailed(String quizId, String imageUrl) =>
      _analytics.track('image_load_failed',
          category: 'quiz', targetType: 'quiz', targetId: quizId,
          payload: {'quiz_id': quizId, 'image_url': imageUrl});
}
