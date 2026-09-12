import 'package:flutter/material.dart';
import '../../domain/quiz_question.dart';
import '../../domain/quiz_answer.dart';
import '../constants.dart';
import '../widgets/quiz_action_button.dart';
import '../widgets/inline_answer_field.dart';
import '../widgets/option_picker_sheet.dart';

class ClozeBody extends StatefulWidget {
  const ClozeBody({super.key, required this.question,
    required this.onAnswer, required this.locked, this.existingAnswer});
  final QuizQuestion question;
  final ValueChanged<QuizAnswer> onAnswer;
  final bool locked;
  final QuizAnswer? existingAnswer;
  @override
  State<ClozeBody> createState() => _ClozeBodyState();
}

class _ClozeBodyState extends State<ClozeBody> {
  final _ctrls = <int, TextEditingController>{};
  final _dropdownValues = <int, String?>{};
  late final List _blanks;

  @override
  void initState() {
    super.initState();
    _blanks = (widget.question.answerKey['blanks'] as List?) ?? [];
    final prev = widget.existingAnswer;
    final a = prev is ClozeAnswer ? prev.answers : <int, String>{};
    for (final b in _blanks) {
      final m = b as Map;
      final id = m['id'] as int? ?? m['position'] as int;
      final type = m['type'] as String? ?? 'free_text';
      if (type == 'free_text') {
        _ctrls[id] = TextEditingController(text: a[id] ?? '');
      } else {
        _dropdownValues[id] = a[id];
      }
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) { c.dispose(); }
    super.dispose();
  }

  void _submit() {
    final answers = <int, String>{};
    _ctrls.forEach((k, v) => answers[k] = v.text.trim());
    _dropdownValues.forEach((k, v) { if (v != null) answers[k] = v; });
    widget.onAnswer(
        ClozeAnswer(questionId: widget.question.id, answers: answers));
  }

  @override
  Widget build(BuildContext context) {
    final txt = widget.question.answerKey['text'] as String? ?? '';
    final l = widget.locked;
    final tStyle = TextStyle(color: cream900, fontSize: 16);
    final parts = txt.split(RegExp(r'\{\{blank_\d+\}\}'));
    final matches = RegExp(r'\{\{blank_(\d+)\}\}').allMatches(txt).toList();
    final spans = <InlineSpan>[];
    final canSubmit = _canSubmit();
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

  bool _canSubmit() {
    for (final b in _blanks.cast<Map>()) {
      final id = (b['id'] as int?) ?? (b['position'] as int?) ?? 0;
      final type = b['type'] as String? ?? 'free_text';
      if (type == 'dropdown') {
        if ((_dropdownValues[id] ?? '').isEmpty) return false;
        continue;
      }
      if ((_ctrls[id]?.text.trim() ?? '').isEmpty) return false;
    }
    return _blanks.isNotEmpty;
  }

  InlineSpan _locked(int id) {
    final blank = _blanks.cast<Map>().firstWhere(
      (b) => (b['id'] as int?) == id || (b['position'] as int?) == id,
      orElse: () => {});
    final ans = blank['correct_answer'] as String? ?? '?';
    return TextSpan(text: ' $ans ',
      style: TextStyle(color: success600, fontWeight: FontWeight.bold));
  }

  InlineSpan _editable(int id, TextStyle s) {
    final blank = _blanks.cast<Map>().firstWhere(
      (b) => (b['id'] as int?) == id || (b['position'] as int?) == id,
      orElse: () => {});
    final type = blank['type'] as String? ?? 'free_text';
    if (type == 'dropdown') {
      final options = (blank['dropdown_options'] as List?)
          ?.map((e) => '$e').toList() ?? [];
      return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: OptionPickerField(
            options: options.map((o) => (o, o)).toList(),
            selectedId: _dropdownValues[id],
            compact: true,
            onSelected: (v) => setState(() { _dropdownValues[id] = v; }),
          ),
        ),
      );
    }
    return inlineAnswerField(
      controller: _ctrls[id]!,
      style: s,
      onChanged: () => setState(() {}),
    );
  }
}
