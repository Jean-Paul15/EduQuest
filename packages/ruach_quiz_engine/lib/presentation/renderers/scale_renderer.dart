import 'package:flutter/material.dart';
import '../../domain/quiz_answer.dart';
import '../constants.dart';
import '../tokens.dart';
import 'question_renderer.dart';

/// Échelle numérique. Deux rendus selon `answer_key` :
/// - pastilles (défaut, Likert 1-5) ;
/// - curseur si `display == 'slider'` ou si l'amplitude dépasse 10
///   (ex. confiance 0-100 par pas de 10 — SCCT).
class ScaleRenderer extends QuestionRenderer {
  const ScaleRenderer({
    super.key,
    required super.question,
    required super.onAnswer,
    super.locked,
    super.editable,
    super.existingAnswer,
  });

  int get _min => (question.answerKey['min'] as num?)?.toInt() ?? 1;
  int get _max => (question.answerKey['max'] as num?)?.toInt() ?? 5;
  int get _step => (question.answerKey['step'] as num?)?.toInt() ?? 1;
  int? get _selected =>
      existingAnswer is ScaleAnswer ? (existingAnswer as ScaleAnswer).selected : null;
  bool get _asSlider =>
      question.answerKey['display'] == 'slider' || (_max - _min) > 10;
  bool get _readOnly => locked && !editable;

  void _emit(int value) =>
      onAnswer(ScaleAnswer(questionId: question.id, selected: value));

  @override
  Widget build(BuildContext context) {
    final minLabel = question.answerKey['min_label']?.toString() ?? 'Peu';
    final maxLabel = question.answerKey['max_label']?.toString() ?? 'Beaucoup';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _endLabel(minLabel, TextAlign.left)),
            const SizedBox(width: 12),
            Expanded(child: _endLabel(maxLabel, TextAlign.right)),
          ],
        ),
        const SizedBox(height: 10),
        _asSlider ? _slider(context) : _pills(),
      ],
    );
  }

  Widget _endLabel(String text, TextAlign align) => Text(
    text,
    softWrap: true,
    textAlign: align,
    style: TextStyle(color: cream700, fontSize: 12),
  );

  Widget _slider(BuildContext context) {
    final value = (_selected ?? ((_min + _max) ~/ 2)).clamp(_min, _max);
    final divisions = ((_max - _min) / _step).round().clamp(1, 100);
    return Semantics(
      slider: true,
      label: question.prompt,
      value: '$value',
      child: Column(
        children: [
          Slider(
            value: value.toDouble(),
            min: _min.toDouble(),
            max: _max.toDouble(),
            divisions: divisions,
            label: '$value',
            onChanged: _readOnly ? null : (v) => _emit(v.round()),
          ),
          Text(
            '$value',
            style: TextStyle(color: gold500, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _pills() => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: List.generate(_max - _min + 1, (index) {
      final value = _min + index;
      final selected = _selected == value;
      return Semantics(
        button: true,
        selected: selected,
        label: '$value${selected ? ', sélectionné' : ''}',
        child: InkWell(
          onTap: _readOnly ? null : () => _emit(value),
          borderRadius: BorderRadius.circular(QuizRadius.full),
          child: AnimatedContainer(
            duration: QuizMotion.tap,
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? gold500.withAlpha(28) : surfaceBase,
              borderRadius: BorderRadius.circular(QuizRadius.full),
              border: Border.all(
                color: selected ? gold500 : cream200,
                width: selected ? 1.6 : 1.1,
              ),
            ),
            child: Text(
              '$value',
              style: TextStyle(
                color: selected ? gold500 : cream900,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }),
  );
}
