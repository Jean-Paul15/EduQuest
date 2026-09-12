import 'package:flutter/material.dart';
import '../../domain/quiz_question.dart';
import '../../domain/quiz_answer.dart';
import '../constants.dart';
import '../widgets/quiz_action_button.dart';
import '../widgets/option_picker_sheet.dart';
import '../quiz_icons.dart';
import '../tokens.dart';

class MatchingBody extends StatefulWidget {
  const MatchingBody({super.key, required this.question,
    required this.onAnswer, required this.locked, this.existingAnswer});
  final QuizQuestion question;
  final ValueChanged<QuizAnswer> onAnswer;
  final bool locked;
  final QuizAnswer? existingAnswer;
  @override
  State<MatchingBody> createState() => _MatchingBodyState();
}

class _MatchingBodyState extends State<MatchingBody> {
  final _pairs = <String, String>{};
  late final List<Map<String, dynamic>> _left;
  late final List<Map<String, dynamic>> _right;

  @override
  void initState() {
    super.initState();
    final prev = widget.existingAnswer;
    if (prev is MatchingAnswer) _pairs.addAll(prev.pairs);
    _left = ((widget.question.answerKey['left_items'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    _right = ((widget.question.answerKey['right_items'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  void _setPair(String leftId, String? rightId) {
    if (widget.locked) return;
    setState(() {
      if (rightId == null || rightId.isEmpty) {
        _pairs.remove(leftId);
      } else {
        _pairs[leftId] = rightId;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.locked;
    final canSubmit = _left.isNotEmpty && _pairs.length == _left.length;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ..._left.map((li) => _pairRow(li, l)),
      if (!l) ...[
        const SizedBox(height: 10),
        QuizActionButton(
          label: 'Valider les associations',
          onPressed: canSubmit
              ? () => widget.onAnswer(
                  MatchingAnswer(
                    questionId: widget.question.id,
                    pairs: Map.from(_pairs),
                  ),
                )
              : null,
        ),
      ],
    ]);
  }

  Widget _pairRow(Map<String, dynamic> li, bool l) {
    final lid = '${li['id']}';
    final leftLabel = li['label'] as String? ?? li['content']?['value'] ?? '';
    final selectedId = _pairs[lid];
    final selectedLabel = _rightLabel(selectedId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(child: _labelCard(leftLabel, true, gold500)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(QuizIcons.arrowForward, color: cream700, size: 18)),
        Expanded(
          child: l
              ? _locked(selectedLabel)
              : _picker(lid, selectedId),
        ),
      ]),
    );
  }

  List<Map<String, dynamic>> _availableRights(String leftId) {
    final selected = _pairs[leftId];
    return _right.where((item) {
      final id = '${item['id']}';
      return id == selected || !_pairs.values.contains(id);
    }).toList();
  }

  String _rightLabel(String? id) {
    if (id == null || id.isEmpty) return '';
    final match = _right.where((item) => '${item['id']}' == id);
    if (match.isEmpty) return '';
    final item = match.first;
    return item['label'] as String? ?? item['content']?['value'] ?? '';
  }

  Widget _labelCard(String label, bool active, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      color: active ? color.withAlpha(18) : ink800,
      borderRadius: BorderRadius.circular(QuizRadius.sm),
      border: Border.all(color: active ? color : cream200, width: 1.4),
    ),
    child: Text(
      label,
      style: TextStyle(color: active ? color : cream700, fontSize: 14),
    ),
  );

  Widget _picker(String leftId, String? selectedId) {
    final options = _availableRights(leftId)
        .map((item) => ('${item['id']}', _rightLabel('${item['id']}')))
        .toList();
    return OptionPickerField(
      options: options,
      selectedId: selectedId,
      hint: 'Associer',
      onSelected: (value) => _setPair(leftId, value),
    );
  }

  Widget _locked(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(color: ink800,
        borderRadius: BorderRadius.circular(QuizRadius.sm),
        border: Border.all(color: success600)),
    child: Text(label, style: TextStyle(
        color: success600, fontSize: 14, fontWeight: FontWeight.w500)));
}
