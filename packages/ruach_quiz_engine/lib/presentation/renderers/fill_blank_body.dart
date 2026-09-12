import 'package:flutter/material.dart';
import '../../domain/quiz_question.dart';
import '../../domain/quiz_answer.dart';
import '../constants.dart';
import '../widgets/quiz_action_button.dart';
import '../widgets/inline_answer_field.dart';

class FillBlankBody extends StatefulWidget {
  const FillBlankBody({super.key, required this.question,
    required this.onAnswer, required this.locked, this.existingAnswer});
  final QuizQuestion question;
  final ValueChanged<QuizAnswer> onAnswer;
  final bool locked;
  final QuizAnswer? existingAnswer;
  @override
  State<FillBlankBody> createState() => _FillBlankBodyState();
}

class _FillBlankBodyState extends State<FillBlankBody> {
  final _ctrls = <int, TextEditingController>{};
  late final List _blanks;

  @override
  void initState() {
    super.initState();
    final a = widget.existingAnswer;
    final prev = a is FillBlankAnswer ? a.answers : <int, String>{};
    _blanks = (widget.question.answerKey['blanks'] as List?) ?? [];
    for (final b in _blanks) {
      final pos = (b as Map)['position'] as int;
      _ctrls[pos] = TextEditingController(text: prev[pos] ?? '');
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
    widget.onAnswer(FillBlankAnswer(questionId: widget.question.id, answers: a));
  }

  @override
  Widget build(BuildContext context) {
    final txt = widget.question.answerKey['text'] as String? ?? '';
    final l = widget.locked;
    final tStyle = TextStyle(color: cream900, fontSize: 16);
    final spans = _buildSpans(txt, l, tStyle);
    final canSubmit = _ctrls.values.every((c) => c.text.trim().isNotEmpty);

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

  List<InlineSpan> _buildSpans(String txt, bool l, TextStyle tStyle) {
    final parts = txt.split('___');
    final spans = <InlineSpan>[];
    for (var i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i]));
      if (i >= parts.length - 1) break;
      final pos = i + 1;
      spans.add(l ? _lockedBlank(pos) : _editableBlank(pos, tStyle));
    }
    return spans;
  }

  /// Affiche ce que l'utilisateur a reellement saisi, jamais la reponse
  /// attendue a sa place -- l'ancienne version affichait toujours la bonne
  /// reponse en vert quel que soit ce qui avait ete tape, donnant
  /// l'impression trompeuse que tout est toujours valide.
  InlineSpan _lockedBlank(int pos) {
    for (final b in _blanks) {
      final m = b as Map;
      if (m['position'] != pos) continue;
      final expected = '${m['answer'] ?? ''}';
      final given = _ctrls[pos]?.text.trim() ?? '';
      final correct = expected.trim().toLowerCase() == given.toLowerCase();
      final shown = given.isEmpty ? '?' : given;
      if (correct) {
        return TextSpan(text: ' $shown ',
            style: TextStyle(color: success600,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline));
      }
      return TextSpan(children: [
        TextSpan(text: ' $shown ',
            style: TextStyle(color: error400,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.lineThrough)),
        TextSpan(text: '($expected) ',
            style: TextStyle(color: success600, fontWeight: FontWeight.bold)),
      ]);
    }
    return const TextSpan(text: ' ? ');
  }

  InlineSpan _editableBlank(int pos, TextStyle tStyle) => inlineAnswerField(
        controller: _ctrls[pos]!,
        style: tStyle,
        onChanged: () => setState(() {}),
      );
}
