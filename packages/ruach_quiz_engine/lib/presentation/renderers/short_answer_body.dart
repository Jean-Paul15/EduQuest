import 'package:flutter/material.dart';
import '../../domain/quiz_question.dart';
import '../../domain/quiz_answer.dart';
import '../constants.dart';
import '../tokens.dart';
import '../widgets/quiz_action_button.dart';

class ShortAnswerBody extends StatefulWidget {
  const ShortAnswerBody({super.key, required this.question,
    required this.onAnswer, required this.locked, this.existingAnswer});
  final QuizQuestion question;
  final ValueChanged<QuizAnswer> onAnswer;
  final bool locked;
  final QuizAnswer? existingAnswer;
  @override
  State<ShortAnswerBody> createState() => _ShortAnswerBodyState();
}

class _ShortAnswerBodyState extends State<ShortAnswerBody> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final a = widget.existingAnswer;
    _ctrl = TextEditingController(text: a is ShortAnswerAnswer ? a.text : '');
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l = widget.locked;
    final r = BorderRadius.circular(QuizRadius.md);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (l)
        _lockedView(r)
      else ...[
        _editableField(r),
        const SizedBox(height: 12),
        _submitButton(r),
      ],
    ]);
  }

  Widget _lockedView(BorderRadius r) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: surfaceBase,
      border: Border.all(color: cream200),
      borderRadius: r,
    ),
    child: Text('(correction manuelle)',
        style: TextStyle(color: cream700, fontStyle: FontStyle.italic, fontSize: 14)));

  Widget _editableField(BorderRadius r) => TextField(
    controller: _ctrl,
    minLines: 3,
    maxLines: null,
    onChanged: (_) => setState(() {}),
    style: TextStyle(color: cream900, fontSize: 15),
    decoration: InputDecoration(
      hintText: 'Écrivez votre réponse ici…',
      hintStyle: TextStyle(color: cream700),
      filled: true,
      fillColor: surfaceBase,
      contentPadding: const EdgeInsets.all(12),
      border: OutlineInputBorder(borderRadius: r,
          borderSide: BorderSide(color: cream200)),
      enabledBorder: OutlineInputBorder(borderRadius: r,
          borderSide: BorderSide(color: cream200)),
      focusedBorder: OutlineInputBorder(borderRadius: r,
          borderSide: BorderSide(color: gold500, width: 2)),
    ));

  Widget _submitButton(BorderRadius r) => QuizActionButton(
    label: 'Soumettre',
    onPressed: _ctrl.text.trim().isEmpty
        ? null
        : () => widget.onAnswer(ShortAnswerAnswer(
              questionId: widget.question.id,
              text: _ctrl.text,
            )),
  );
}
