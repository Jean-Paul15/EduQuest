import '../domain/quiz_question.dart';

/// Interface pour le tracking analytics des sessions de quiz.
/// L'application hôte fournit l'implémentation concrète (Drift, Supabase...).
abstract class QuizAnalyticsInterface {
  void trackQuizStarted(String quizId, String title, int totalQuestions);
  void trackQuestionAnswered(String quizId, String questionId,
      QuestionType type, bool correct, int timeSeconds);
  void trackQuestionSkipped(String quizId, String questionId);
  void trackQuizCompleted(String quizId, double scorePercent,
      bool passed, int totalTimeSeconds, int correctCount, int totalQuestions);
  void trackQuizAbandoned(String quizId, int questionIndex, int elapsedSeconds);

  /// §14.1 : image cassée/inaccessible — signal pour détecter les médias
  /// morts (formateur à prévenir) sans jamais impacter l'UI de l'élève.
  void trackImageLoadFailed(String quizId, String imageUrl);
}

/// Implémentation muette pour les cas où le tracking n'est pas configuré.
class NoOpAnalytics implements QuizAnalyticsInterface {
  const NoOpAnalytics();
  @override void trackQuizStarted(String a, String b, int c) {}
  @override void trackQuestionAnswered(String a, String b, QuestionType c, bool d, int e) {}
  @override void trackQuestionSkipped(String a, String b) {}
  @override void trackQuizCompleted(String a, double b, bool c, int d, int e, int f) {}
  @override void trackQuizAbandoned(String a, int b, int c) {}
  @override void trackImageLoadFailed(String a, String b) {}
}
