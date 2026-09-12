import 'package:flutter/material.dart';
import '../../domain/quiz_answer.dart';
import '../../domain/quiz_question.dart';
import '../constants.dart';
import '../quiz_icons.dart';
import '../tokens.dart';
import 'question_renderer.dart';

class SingleChoiceRenderer extends QuestionRenderer {
  const SingleChoiceRenderer({
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
  String? _picked;
  @override
  void initState() {
    super.initState();
    final a = widget.existingAnswer;
    _picked = a is SingleChoiceAnswer ? a.selected : null;
  }

  @override
  void didUpdateWidget(covariant _Body oldWidget) {
    super.didUpdateWidget(oldWidget);
    final a = widget.existingAnswer;
    if (a is SingleChoiceAnswer) _picked = a.selected;
  }

  /// Sans [requireValidation] : soumet directement, comme avant (le bouton
  /// unique de la barre du bas passera a "Continuer" des le verrouillage).
  /// Avec [requireValidation] : ne fait que signaler la selection via
  /// [onDraft] -- c'est le bouton "Valider" de la barre du bas qui soumet.
  void _tap(String o) {
    if (widget.locked && !widget.editable) return;
    if (!widget.requireValidation) {
      widget.onAnswer(
          SingleChoiceAnswer(questionId: widget.question.id, selected: o));
      return;
    }
    setState(() => _picked = o);
    widget.onDraft?.call(
        SingleChoiceAnswer(questionId: widget.question.id, selected: o));
  }

  @override
  Widget build(BuildContext context) {
    final opts = List<String>.from(widget.question.answerKey['options'] ?? []);
    final correct = widget.question.answerKey['answer'] as String? ?? '';
    final existing = widget.existingAnswer;
    final sel = widget.requireValidation
        ? _picked
        : (existing is SingleChoiceAnswer ? existing.selected : null);
    final l = widget.locked && !widget.editable;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ...opts.map((o) {
        final picked = sel == o;
        final ok = correct == o;
        final border = l
            ? (ok ? success600 : (picked ? error400 : cream200))
            : (picked ? gold500 : cream200);
        final textColor = l && ok
            ? success600
            : (l && picked && !ok ? error400 : cream900);
        final stateLabel = l
            ? (ok ? ', correct' : (picked ? ', incorrect' : ''))
            : (picked ? ', sélectionné' : '');
        return Semantics(
          button: true,
          selected: picked,
          label: '$o$stateLabel',
          child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(QuizRadius.md),
            onTap: l ? null : () => _tap(o),
            child: AnimatedContainer(
              duration: QuizMotion.tap,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: border, width: picked ? 1.6 : 1.2),
                borderRadius: BorderRadius.circular(QuizRadius.md),
                color: picked && !l ? gold500.withAlpha(22) : surfaceBase,
              ),
              child: Row(children: [
                Icon(
                  picked
                      ? QuizIcons.radioButtonChecked
                      : QuizIcons.radioButtonUnchecked,
                  size: 20,
                  color: l
                      ? (ok ? success600 : cream700)
                      : (picked ? gold500 : cream700),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    o,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: picked ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ]),
            ),
          ),
          ),
        );
      }),
    ]);
  }
}
