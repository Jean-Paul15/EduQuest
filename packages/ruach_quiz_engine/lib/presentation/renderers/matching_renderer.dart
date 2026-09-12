import 'package:flutter/material.dart';
import 'question_renderer.dart';
import 'matching_body.dart';

/// Wrapper pour le renderer matching (tap).
class MatchingRenderer extends QuestionRenderer {
  const MatchingRenderer({super.key, required super.question,
    required super.onAnswer, super.locked = false, super.existingAnswer});
  @override
  Widget build(BuildContext context) =>
      MatchingBody(question: question, onAnswer: onAnswer,
          locked: locked, existingAnswer: existingAnswer);
}
