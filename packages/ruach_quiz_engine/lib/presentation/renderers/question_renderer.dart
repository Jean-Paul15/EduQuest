import 'package:flutter/material.dart';
import '../../domain/quiz_question.dart';
import '../../domain/quiz_answer.dart';
import 'single_choice_renderer.dart';
import 'multi_choice_renderer.dart';
import 'true_false_renderer.dart';
import 'scale_renderer.dart';
import 'fill_blank_renderer.dart';
import 'fill_blanks_renderer.dart';
import 'cloze_renderer.dart';
import 'matching_renderer.dart';
import 'short_answer_renderer.dart';

/// Abstract renderer for a quiz question.
/// Use [QuestionRenderer.forType] to obtain the correct concrete renderer.
abstract class QuestionRenderer extends StatelessWidget {
  const QuestionRenderer({
    super.key,
    required this.question,
    required this.onAnswer,
    this.locked = false,
    this.editable = false,
    this.existingAnswer,
    this.requireValidation = false,
    this.onDraft,
  });

  final QuizQuestion question;
  final ValueChanged<QuizAnswer> onAnswer;
  final bool locked;
  final bool editable;
  final QuizAnswer? existingAnswer;

  /// Seuls singleChoice/trueFalse/multiChoice en tiennent compte : quand
  /// vrai, la selection ne soumet pas au premier tap -- elle est juste
  /// signalee via [onDraft] pour que le bouton unique de la barre du bas
  /// (Valider -> Continuer, [QuizBottomBar]) la soumette lui-meme. Quand
  /// faux (pas de feedback immediat configure pour ce quiz -- un palier
  /// "Valider" separe n'aurait alors aucun effet visible), la selection
  /// soumet directement via [onAnswer], comme avant.
  final bool requireValidation;

  /// Appele par singleChoice/trueFalse/multiChoice quand [requireValidation]
  /// est vrai, a chaque changement de selection non encore soumise -- lit
  /// par [QuizBottomBar] via `controller.draftAnswer`. `null` si la
  /// selection est videe.
  final ValueChanged<QuizAnswer?>? onDraft;

  static QuestionRenderer forType(
    QuestionType type, {
    required QuizQuestion question,
    required ValueChanged<QuizAnswer> onAnswer,
    bool locked = false,
    bool editable = false,
    QuizAnswer? existingAnswer,
    bool requireValidation = false,
    ValueChanged<QuizAnswer?>? onDraft,
  }) => switch (type) {
    QuestionType.singleChoice => SingleChoiceRenderer(
      question: question,
      onAnswer: onAnswer,
      locked: locked,
      editable: editable,
      existingAnswer: existingAnswer,
      requireValidation: requireValidation,
      onDraft: onDraft,
    ),
    QuestionType.multiChoice => MultiChoiceRenderer(
      question: question,
      onAnswer: onAnswer,
      locked: locked,
      editable: editable,
      existingAnswer: existingAnswer,
      requireValidation: requireValidation,
      onDraft: onDraft,
    ),
    QuestionType.trueFalse => TrueFalseRenderer(
      question: question,
      onAnswer: onAnswer,
      locked: locked,
      editable: editable,
      existingAnswer: existingAnswer,
      requireValidation: requireValidation,
      onDraft: onDraft,
    ),
    QuestionType.scale => ScaleRenderer(
      question: question,
      onAnswer: onAnswer,
      locked: locked,
      editable: editable,
      existingAnswer: existingAnswer,
    ),
    QuestionType.fillBlank => FillBlankRenderer(
      question: question,
      onAnswer: onAnswer,
      locked: locked,
      existingAnswer: existingAnswer,
    ),
    QuestionType.fillBlanks => FillBlanksRenderer(
      question: question,
      onAnswer: onAnswer,
      locked: locked,
      existingAnswer: existingAnswer,
    ),
    QuestionType.cloze => ClozeRenderer(
      question: question,
      onAnswer: onAnswer,
      locked: locked,
      existingAnswer: existingAnswer,
    ),
    QuestionType.matching => MatchingRenderer(
      question: question,
      onAnswer: onAnswer,
      locked: locked,
      existingAnswer: existingAnswer,
    ),
    QuestionType.shortAnswer => ShortAnswerRenderer(
      question: question,
      onAnswer: onAnswer,
      locked: locked,
      existingAnswer: existingAnswer,
    ),
  };
}
