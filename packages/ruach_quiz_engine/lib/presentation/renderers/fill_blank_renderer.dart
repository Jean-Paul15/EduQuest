import 'package:flutter/material.dart';
import 'question_renderer.dart';
import 'fill_blank_body.dart';

class FillBlankRenderer extends QuestionRenderer {
  const FillBlankRenderer({
    super.key,
    required super.question,
    required super.onAnswer,
    super.locked,
    super.existingAnswer,
  });

  @override
  Widget build(BuildContext context) => FillBlankBody(
      question: question,
      onAnswer: onAnswer,
      locked: locked,
      existingAnswer: existingAnswer);
}
