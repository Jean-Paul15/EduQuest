import '../domain/quiz_answer.dart';

class QuizAnswerCodec {
  static Map<String, dynamic> toMap(QuizAnswer answer) => switch (answer) {
    SingleChoiceAnswer() => {
      'kind': 'single',
      'questionId': answer.questionId,
      'selected': answer.selected,
    },
    MultiChoiceAnswer() => {
      'kind': 'multi',
      'questionId': answer.questionId,
      'selected': answer.selected,
    },
    TrueFalseAnswer() => {
      'kind': 'bool',
      'questionId': answer.questionId,
      'selected': answer.selected,
    },
    ScaleAnswer() => {
      'kind': 'scale',
      'questionId': answer.questionId,
      'selected': answer.selected,
    },
    FillBlankAnswer() => {
      'kind': 'fill_blank',
      'questionId': answer.questionId,
      'answers': _stringify(answer.answers),
    },
    FillBlanksAnswer() => {
      'kind': 'fill_blanks',
      'questionId': answer.questionId,
      'answers': _stringify(answer.answers),
    },
    ClozeAnswer() => {
      'kind': 'cloze',
      'questionId': answer.questionId,
      'answers': _stringify(answer.answers),
    },
    MatchingAnswer() => {
      'kind': 'matching',
      'questionId': answer.questionId,
      'pairs': answer.pairs,
    },
    ShortAnswerAnswer() => {
      'kind': 'short',
      'questionId': answer.questionId,
      'text': answer.text,
    },
  };

  static QuizAnswer? fromMap(Map<String, dynamic> raw) {
    final id = raw['questionId']?.toString();
    if (id == null || id.isEmpty) return null;
    return switch (raw['kind']) {
      'single' => SingleChoiceAnswer(
        questionId: id,
        selected: raw['selected']?.toString() ?? '',
      ),
      'multi' => MultiChoiceAnswer(
        questionId: id,
        selected: (raw['selected'] as List? ?? const [])
            .map((e) => '$e')
            .toList(),
      ),
      'bool' => TrueFalseAnswer(
        questionId: id,
        selected: raw['selected'] == true,
      ),
      'scale' => ScaleAnswer(
        questionId: id,
        selected: (raw['selected'] as num?)?.toInt() ?? 1,
      ),
      'fill_blank' => FillBlankAnswer(
        questionId: id,
        answers: _intMap(raw['answers']),
      ),
      'fill_blanks' => FillBlanksAnswer(
        questionId: id,
        answers: _intMap(raw['answers']),
      ),
      'cloze' => ClozeAnswer(questionId: id, answers: _intMap(raw['answers'])),
      'matching' => MatchingAnswer(
        questionId: id,
        pairs: Map<String, String>.from((raw['pairs'] as Map?) ?? {}),
      ),
      'short' => ShortAnswerAnswer(
        questionId: id,
        text: raw['text']?.toString() ?? '',
      ),
      _ => null,
    };
  }

  static Map<String, String> _stringify(Map<int, String> values) =>
      values.map((k, v) => MapEntry('$k', v));

  static Map<int, String> _intMap(dynamic raw) {
    final out = <int, String>{};
    final source = Map<String, dynamic>.from((raw as Map?) ?? {});
    source.forEach((k, v) => out[int.tryParse(k) ?? -1] = '$v');
    out.remove(-1);
    return out;
  }
}
