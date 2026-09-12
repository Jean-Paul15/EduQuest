import '../domain/quiz_answer.dart';
import 'quiz_answer_codec.dart';

class QuizSessionSnapshot {
  const QuizSessionSnapshot({
    required this.currentIndex,
    required this.answers,
    required this.spent,
    this.currentLocked = false,
  });

  final int currentIndex;
  final Map<String, QuizAnswer> answers;
  final Map<String, int> spent;
  final bool currentLocked;

  Map<String, dynamic> toMap() => {
    'current_index': currentIndex,
    'answers': answers.values.map(QuizAnswerCodec.toMap).toList(),
    'spent': spent.map((k, v) => MapEntry(k, v)),
    'current_locked': currentLocked,
  };

  static QuizSessionSnapshot? fromMap(Map<String, dynamic>? row) {
    if (row == null || row.isEmpty) return null;
    final answers = <String, QuizAnswer>{};
    for (final raw in (row['answers'] as List? ?? const [])) {
      final answer = QuizAnswerCodec.fromMap(
        Map<String, dynamic>.from(raw as Map),
      );
      if (answer != null) answers[answer.questionId] = answer;
    }
    final spent = <String, int>{};
    Map<String, dynamic>.from(
      (row['spent'] as Map?) ?? {},
    ).forEach((k, v) => spent[k] = (v as num?)?.toInt() ?? 0);
    return QuizSessionSnapshot(
      currentIndex: (row['current_index'] as num?)?.toInt() ?? 0,
      answers: answers,
      spent: spent,
      currentLocked: row['current_locked'] == true,
    );
  }

  static QuizSessionSnapshot? fromRows(List<Map<String, dynamic>>? rows) =>
      rows == null || rows.isEmpty ? null : fromMap(rows.first);
}
