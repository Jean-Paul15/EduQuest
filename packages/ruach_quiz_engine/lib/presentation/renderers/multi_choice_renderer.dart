import 'package:flutter/material.dart';
import '../../domain/quiz_question.dart';
import '../../domain/quiz_answer.dart';
import '../constants.dart';
import '../quiz_icons.dart';
import '../tokens.dart';
import 'question_renderer.dart';

class MultiChoiceRenderer extends QuestionRenderer {
  const MultiChoiceRenderer({
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
  late final List<String> _sel;
  // Une reponse existante signifie deja soumise lors d'une session
  // precedente (reprise) -- ne pas re-declencher onAnswer dans ce cas.
  late bool _submitted;
  @override
  void initState() {
    super.initState();
    final a = widget.existingAnswer;
    _sel = a is MultiChoiceAnswer ? List.from(a.selected) : [];
    _submitted = widget.existingAnswer != null;
  }

  /// Avec [requireValidation] : chaque coche met juste a jour le draft
  /// (bouton "Valider" de la barre du bas qui soumettra). Sans -- soumission
  /// automatique des que l'eleve a coche autant d'options qu'il y a de
  /// bonnes reponses attendues pour CETTE question
  /// (`answerKey['answers'].length`, jamais un seuil fixe), verrouillant la
  /// question et activant "Continuer".
  void _tap(String o) {
    if (widget.locked && !widget.editable) return;
    setState(() => _sel.contains(o) ? _sel.remove(o) : _sel.add(o));
    if (widget.requireValidation) {
      widget.onDraft?.call(_sel.isEmpty
          ? null
          : MultiChoiceAnswer(
              questionId: widget.question.id, selected: List.from(_sel)));
      return;
    }
    final expected =
        (widget.question.answerKey['answers'] as List?)?.length ?? 1;
    if (!_submitted && _sel.length >= expected.clamp(1, 1 << 30)) {
      _submitted = true;
      widget.onAnswer(
        MultiChoiceAnswer(questionId: widget.question.id, selected: List.from(_sel)),
      );
    }
  }

  @override
  void didUpdateWidget(covariant _Body oldWidget) {
    super.didUpdateWidget(oldWidget);
    final answer = widget.existingAnswer;
    if (answer is MultiChoiceAnswer) {
      _sel
        ..clear()
        ..addAll(answer.selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final opts = List<String>.from(widget.question.answerKey['options'] ?? []);
    final corr = List<String>.from(widget.question.answerKey['answers'] ?? []);
    final l = widget.locked && !widget.editable;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ...opts.map((o) {
        final sel = _sel.contains(o);
        final ok = corr.contains(o);
        final border = l
            ? (ok ? success600 : (sel ? error400 : cream200))
            : (sel ? gold500 : cream200);
        final stateLabel = l
            ? (ok ? ', correct' : (sel ? ', incorrect' : ''))
            : (sel ? ', sélectionné' : '');
        return Semantics(
          button: true,
          selected: sel,
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
                border: Border.all(color: border, width: sel ? 1.6 : 1.2),
                borderRadius: BorderRadius.circular(QuizRadius.md),
                color: sel && !l ? gold500.withAlpha(22) : surfaceBase,
              ),
              child: Row(children: [
                Icon(
                  sel ? QuizIcons.checkBox : QuizIcons.checkBoxOutlineBlank,
                  size: 20,
                  color: l
                      ? (ok ? success600 : cream700)
                      : (sel ? gold500 : cream700),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    o,
                    style: TextStyle(
                      color: l && ok
                          ? success600
                          : (l && sel && !ok ? error400 : cream900),
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
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
