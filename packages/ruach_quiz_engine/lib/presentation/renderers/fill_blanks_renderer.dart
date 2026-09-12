import 'package:flutter/material.dart';
import '../../domain/quiz_question.dart';
import '../../domain/quiz_answer.dart';
import '../constants.dart';
import '../widgets/quiz_action_button.dart';
import '../widgets/inline_answer_field.dart';
import 'question_renderer.dart';

/// Wrapper pour le renderer fill_blanks.
class FillBlanksRenderer extends QuestionRenderer {
  const FillBlanksRenderer({super.key, required super.question,
    required super.onAnswer, super.locked = false, super.existingAnswer});
  @override
  Widget build(BuildContext context) =>
      FillBlanksBody(question: question, onAnswer: onAnswer,
          locked: locked, existingAnswer: existingAnswer);
}

class FillBlanksBody extends StatefulWidget {
  const FillBlanksBody({super.key, required this.question,
    required this.onAnswer, required this.locked, this.existingAnswer});
  final QuizQuestion question;
  final ValueChanged<QuizAnswer> onAnswer;
  final bool locked;
  final QuizAnswer? existingAnswer;
  @override
  State<FillBlanksBody> createState() => _FillBlanksBodyState();
}

class _FillBlanksBodyState extends State<FillBlanksBody> {
  final _ctrls = <int, TextEditingController>{};
  late final List _blanks;

  @override
  void initState() {
    super.initState();
    _blanks = (widget.question.answerKey['blanks'] as List?) ?? [];
    final prev = widget.existingAnswer;
    final a = prev is FillBlanksAnswer ? prev.answers : <int, String>{};
    for (final b in _blanks) {
      final pos = (b as Map)['position'] as int;
      _ctrls[pos] = TextEditingController(text: a[pos] ?? '');
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) { c.dispose(); }
    super.dispose();
  }

  void _submit() {
    final a = <int, String>{};
    _ctrls.forEach((k, v) => a[k] = v.text.trim());
    widget.onAnswer(FillBlanksAnswer(
        questionId: widget.question.id, answers: a));
  }

  @override
  Widget build(BuildContext context) {
    final txt = widget.question.answerKey['text'] as String? ?? '';
    final l = widget.locked;
    final tStyle = TextStyle(color: cream900, fontSize: 16);
    final parts = txt.split(RegExp(r'\{\{blank_\d+\}\}'));
    final matches = RegExp(r'\{\{blank_(\d+)\}\}').allMatches(txt).toList();
    final spans = <InlineSpan>[];
    final canSubmit = _ctrls.values.every((c) => c.text.trim().isNotEmpty);
    for (var i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i]));
      if (i >= matches.length) break;
      final pos = int.tryParse(matches[i].group(1)!) ?? i + 1;
      spans.add(l ? _locked(pos) : _editable(pos, tStyle));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      RichText(text: TextSpan(style: tStyle, children: spans)),
      if (!l) ...[
        const SizedBox(height: 12),
        QuizActionButton(
          label: 'Valider',
          onPressed: canSubmit ? _submit : null,
        ),
      ],
    ]);
  }

  InlineSpan _locked(int pos) {
    final blank = _blanks.cast<Map>().firstWhere(
      (b) => b['position'] == pos, orElse: () => {});
    final ans = blank['answer'] as String? ?? '?';
    return TextSpan(text: ' $ans ',
      style: TextStyle(color: success600, fontWeight: FontWeight.bold));
  }

  InlineSpan _editable(int pos, TextStyle s) => inlineAnswerField(
        controller: _ctrls[pos]!,
        style: s,
        onChanged: () => setState(() {}),
      );
}
