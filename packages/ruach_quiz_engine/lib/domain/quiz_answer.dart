/// Réponse d'un utilisateur à une question.
sealed class QuizAnswer {
  const QuizAnswer({required this.questionId});
  final String questionId;
}

class SingleChoiceAnswer extends QuizAnswer {
  const SingleChoiceAnswer({required super.questionId, required this.selected});
  final String selected;
}

class MultiChoiceAnswer extends QuizAnswer {
  const MultiChoiceAnswer({required super.questionId, required this.selected});
  final List<String> selected;
}

class TrueFalseAnswer extends QuizAnswer {
  const TrueFalseAnswer({required super.questionId, required this.selected});
  final bool selected;
}

class ScaleAnswer extends QuizAnswer {
  const ScaleAnswer({required super.questionId, required this.selected});
  final int selected;
}

class FillBlankAnswer extends QuizAnswer {
  const FillBlankAnswer({required super.questionId, required this.answers});
  final Map<int, String> answers; // position → value
}

class FillBlanksAnswer extends QuizAnswer {
  const FillBlanksAnswer({required super.questionId, required this.answers});
  final Map<int, String> answers; // position → value
}

class ClozeAnswer extends QuizAnswer {
  const ClozeAnswer({required super.questionId, required this.answers});
  final Map<int, String> answers; // blank_id → value
}

class MatchingAnswer extends QuizAnswer {
  const MatchingAnswer({required super.questionId, required this.pairs});
  final Map<String, String> pairs; // left_id → right_id
}

class ShortAnswerAnswer extends QuizAnswer {
  const ShortAnswerAnswer({required super.questionId, required this.text});
  final String text;
}
