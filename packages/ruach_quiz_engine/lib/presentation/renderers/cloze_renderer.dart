import 'package:flutter/material.dart';
import 'question_renderer.dart';
import 'cloze_body.dart';

/// Wrapper pour le renderer cloze.
class ClozeRenderer extends QuestionRenderer {
  const ClozeRenderer({super.key, required super.question,
    required super.onAnswer, super.locked = false, super.existingAnswer});
  @override
  Widget build(BuildContext context) =>
      ClozeBody(question: question, onAnswer: onAnswer,
          locked: locked, existingAnswer: existingAnswer);
}
