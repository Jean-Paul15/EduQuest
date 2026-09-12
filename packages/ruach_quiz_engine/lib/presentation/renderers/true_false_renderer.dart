import 'package:flutter/material.dart';
import '../../domain/quiz_answer.dart';
import '../../domain/quiz_question.dart';
import '../constants.dart';
import '../quiz_icons.dart';
import '../tokens.dart';
import 'question_renderer.dart';

class TrueFalseRenderer extends QuestionRenderer {
  const TrueFalseRenderer({
    super.key,
    required super.question,
    required super.onAnswer,
    super.locked,
    super.editable,
    super.existingAnswer,
    super.requireValidation,
    super.onDraft,
  });

  @override
  Widget build(BuildContext context) => _Body(
      question: question,
      onAnswer: onAnswer,
      locked: locked,
      editable: editable,
      existingAnswer: existingAnswer,
      requireValidation: requireValidation,
      onDraft: onDraft);
}

class _Body extends StatefulWidget {
  const _Body({required this.question, required this.onAnswer,
    required this.locked, required this.editable, this.existingAnswer,
    required this.requireValidation, this.onDraft});
  final QuizQuestion question;
  final ValueChanged<QuizAnswer> onAnswer;
  final bool locked;
  final bool editable;
  final QuizAnswer? existingAnswer;
  final bool requireValidation;
  final ValueChanged<QuizAnswer?>? onDraft;
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  bool? _picked;
  @override
  void initState() {
    super.initState();
    final a = widget.existingAnswer;
    _picked = a is TrueFalseAnswer ? a.selected : null;
  }

  @override
  void didUpdateWidget(covariant _Body oldWidget) {
    super.didUpdateWidget(oldWidget);
    final a = widget.existingAnswer;
    if (a is TrueFalseAnswer) _picked = a.selected;
  }

  /// Voir SingleChoiceRenderer._tap — même logique deux-voies (soumission
  /// directe vs signalement de draft) pilotée par [requireValidation].
  void _tap(bool value) {
    if (widget.locked && !widget.editable) return;
    if (!widget.requireValidation) {
      widget.onAnswer(
          TrueFalseAnswer(questionId: widget.question.id, selected: value));
      return;
    }
    setState(() => _picked = value);
    widget.onDraft?.call(
        TrueFalseAnswer(questionId: widget.question.id, selected: value));
  }

  @override
  Widget build(BuildContext context) {
    final correct = widget.question.answerKey['answer'] as bool? ?? false;
    final existing = widget.requireValidation
        ? _picked
        : (widget.existingAnswer is TrueFalseAnswer
            ? (widget.existingAnswer as TrueFalseAnswer).selected
            : null);
    final l = widget.locked && !widget.editable;

    Color borderFor(bool value) {
      if (!l) return (existing == value) ? gold500 : cream200;
      if (value == correct) return success600;
      return (existing == value) ? error400 : cream200;
    }

    Color textColorFor(bool value) {
      if (l && value == correct) return success600;
      if (l && existing == value && value != correct) return error400;
      return cream900;
    }

    Widget button(bool value, String label) {
      final selected = existing == value;
      final stateLabel = l
          ? (value == correct ? ', correct' : (selected ? ', incorrect' : ''))
          : (selected ? ', sélectionné' : '');
      return Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          label: '$label$stateLabel',
          child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(QuizRadius.md),
            onTap: l ? null : () => _tap(value),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: borderFor(value),
                  width: selected ? 1.6 : 1.2,
                ),
                borderRadius: BorderRadius.circular(QuizRadius.md),
                color: selected && !l ? gold500.withAlpha(22) : surfaceBase,
              ),
              child: Column(children: [
                Icon(
                  value ? QuizIcons.checkCircle : QuizIcons.cancel,
                  size: 24,
                  color: l
                      ? (value == correct ? success600 : cream700)
                      : (selected ? gold500 : cream700),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: textColorFor(value),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]),
            ),
          ),
          ),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [button(true, 'Vrai'), button(false, 'Faux')]),
    ]);
  }
}
