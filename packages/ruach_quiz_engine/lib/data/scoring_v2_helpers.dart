import '../domain/quiz_answer.dart';
import '../domain/quiz_question.dart';

/// Helpers de scoring pour les types V2 (fill_blanks, cloze, matching).
class ScoringV2Helpers {
  static Map<String, String> parseMatchingPairs(Map answerKey) {
    final raw = answerKey['correct_pairs'];
    if (raw is Map) return Map<String, String>.from(raw);
    if (raw is List) {
      final m = <String, String>{};
      for (final p in raw) {
        if (p is Map) m['${p['left_id']}'] = '${p['right_id']}';
      }
      return m;
    }
    return {};
  }

  static bool isCorrectFillBlanks(QuizQuestion q, FillBlanksAnswer a) {
    final blanks = q.answerKey['blanks'] as List? ?? [];
    for (final blank in blanks) {
      final b = blank as Map;
      final pos = b['position'] as int;
      final correct = (b['correct_answers'] as List?)?.map((e) =>
        '$e'.trim().toLowerCase()).toList()
        ?? [(b['answer'] as String? ?? '').trim().toLowerCase()];
      final given = (a.answers[pos] ?? '').trim().toLowerCase();
      if (!correct.contains(given)) return false;
    }
    return blanks.isNotEmpty;
  }

  static bool isCorrectCloze(QuizQuestion q, ClozeAnswer a) {
    final blanks = q.answerKey['blanks'] as List? ?? [];
    for (final blank in blanks) {
      final b = blank as Map;
      final id = b['id'] as int? ?? b['position'] as int;
      final expected = (b['correct_answer'] as String).trim().toLowerCase();
      final given = (a.answers[id] ?? '').trim().toLowerCase();
      if (expected != given) return false;
    }
    return blanks.isNotEmpty;
  }

  static bool isCorrectMatching(QuizQuestion q, MatchingAnswer a) {
    final correct = parseMatchingPairs(q.answerKey);
    if (correct.isEmpty) return false;
    return correct.entries.every((e) => a.pairs[e.key] == e.value)
        && a.pairs.length == correct.length;
  }

  static double partialFillBlanks(QuizQuestion q, FillBlanksAnswer a) {
    final blanks = q.answerKey['blanks'] as List? ?? [];
    if (blanks.isEmpty) return 0.0;
    var correct = 0;
    for (final blank in blanks) {
      final b = blank as Map;
      final pos = b['position'] as int;
      final answers = (b['correct_answers'] as List?)
          ?.map((e) => '$e'.trim().toLowerCase()).toList()
          ?? [(b['answer'] as String? ?? '').trim().toLowerCase()];
      final given = (a.answers[pos] ?? '').trim().toLowerCase();
      if (answers.contains(given)) correct++;
    }
    return q.points * (correct / blanks.length);
  }

  static double partialMatching(QuizQuestion q, MatchingAnswer a) {
    final correct = parseMatchingPairs(q.answerKey);
    if (correct.isEmpty) return 0.0;
    var matches = 0;
    for (final e in correct.entries) {
      if (a.pairs[e.key] == e.value) matches++;
    }
    return q.points * (matches / correct.length);
  }
}
