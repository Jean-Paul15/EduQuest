import 'package:flutter/material.dart';
import 'question_renderer.dart';
import 'short_answer_body.dart';

class ShortAnswerRenderer extends QuestionRenderer {
  const ShortAnswerRenderer({
    super.key,
    required super.question,
    required super.onAnswer,
    super.locked,
    super.existingAnswer,
  });

  @override
  Widget build(BuildContext context) => ShortAnswerBody(
      question: question,
      onAnswer: onAnswer,
      locked: locked,
      existingAnswer: existingAnswer);
}
