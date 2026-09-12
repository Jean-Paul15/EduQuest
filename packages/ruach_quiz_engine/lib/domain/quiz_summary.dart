/// Lightweight quiz identity used for listing quizzes (chapter view, catalog).
/// The full [QuizDefinition] is loaded only when a quiz attempt starts.
class QuizSummary {
  const QuizSummary({
    required this.id,
    required this.title,
    this.questionCount,
    this.timePerQuestionSeconds,
  });
  final String id;
  final String title;

  /// null tant que la source (RPC list_quizzes_for_chapter) ne fournit pas
  /// ce champ — les écrans consommateurs doivent masquer l'info plutôt que
  /// d'afficher "null".
  final int? questionCount;
  final int? timePerQuestionSeconds;
}
