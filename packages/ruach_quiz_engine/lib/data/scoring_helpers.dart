import '../domain/quiz_answer.dart';
import '../domain/quiz_question.dart';
import 'scoring_v2_helpers.dart';

/// Fonctions helper pour le scoring : correction et formatage des réponses.
class ScoringHelpers {
  static bool isCorrect(QuizQuestion q, QuizAnswer a) => switch (q.type) {
    QuestionType.singleChoice => _singleChoice(q, a),
    QuestionType.multiChoice => _multiChoice(q, a),
    QuestionType.trueFalse => _trueFalse(q, a),
    QuestionType.scale => a is ScaleAnswer,
    QuestionType.fillBlank => a is FillBlankAnswer ? _fillBlank(q, a) : false,
    QuestionType.fillBlanks =>
      a is FillBlanksAnswer
          ? ScoringV2Helpers.isCorrectFillBlanks(q, a)
          : false,
    QuestionType.cloze =>
      a is ClozeAnswer ? ScoringV2Helpers.isCorrectCloze(q, a) : false,
    QuestionType.matching =>
      a is MatchingAnswer ? ScoringV2Helpers.isCorrectMatching(q, a) : false,
    QuestionType.shortAnswer => true,
  };

  /// false pour les types sans vérité binaire (échelle subjective, réponse
  /// libre à corriger manuellement) — sert à éviter d'afficher "Bonne réponse !"
  /// alors qu'isCorrect() renvoie toujours true par convention pour ces types.
  static bool isGradable(QuestionType t) =>
      t != QuestionType.scale && t != QuestionType.shortAnswer;

  static bool _singleChoice(QuizQuestion q, QuizAnswer a) =>
      a is SingleChoiceAnswer && a.selected == q.answerKey['answer'];

  static bool _multiChoice(QuizQuestion q, QuizAnswer a) {
    if (a is! MultiChoiceAnswer) return false;
    final correct = List<String>.from(q.answerKey['answers'] ?? []);
    if (correct.isEmpty) return false;
    final sel = a.selected.toSet(), cor = correct.toSet();
    return sel.length == cor.length && sel.containsAll(cor);
  }

  static bool _trueFalse(QuizQuestion q, QuizAnswer a) =>
      a is TrueFalseAnswer && a.selected == q.answerKey['answer'];

  static bool _fillBlank(QuizQuestion q, FillBlankAnswer a) {
    final blanks = q.answerKey['blanks'] as List? ?? [];
    for (final blank in blanks) {
      final b = blank as Map, pos = b['position'] as int;
      final expected = (b['answer'] as String).trim().toLowerCase();
      final given = (a.answers[pos] ?? '').trim().toLowerCase();
      if (expected != given) return false;
    }
    return blanks.isNotEmpty;
  }

  static String? userAnswerString(QuizAnswer a) {
    return switch (a) {
      SingleChoiceAnswer(selected: final s) => s,
      MultiChoiceAnswer(selected: final s) => s.join(', '),
      TrueFalseAnswer(selected: final s) => s ? 'Vrai' : 'Faux',
      ScaleAnswer(selected: final s) => '$s',
      FillBlankAnswer(answers: final a) =>
        a.entries.map((e) => '${e.key}:${e.value}').join('; '),
      FillBlanksAnswer(answers: final a) =>
        a.entries.map((e) => '#${e.key} ${e.value}').join(', '),
      ClozeAnswer(answers: final a) =>
        a.entries.map((e) => '#${e.key} ${e.value}').join(', '),
      MatchingAnswer(pairs: final p) =>
        p.entries.map((e) => '${e.key}→${e.value}').join(', '),
      ShortAnswerAnswer(text: final t) => t,
    };
  }

  /// Points gagnés pour une question (supporte partial_credit).
  static double pointsEarned(QuizQuestion q, QuizAnswer a, bool partialCredit) {
    if (isCorrect(q, a)) return q.points.toDouble();
    if (!partialCredit) return 0.0;
    if (q.type == QuestionType.multiChoice) return _partialMultiChoice(q, a);
    if (q.type == QuestionType.fillBlanks && a is FillBlanksAnswer) {
      return ScoringV2Helpers.partialFillBlanks(q, a);
    }
    if (q.type == QuestionType.matching && a is MatchingAnswer) {
      return ScoringV2Helpers.partialMatching(q, a);
    }
    return 0.0;
  }

  static double _partialMultiChoice(QuizQuestion q, QuizAnswer a) {
    if (q.type != QuestionType.multiChoice || a is! MultiChoiceAnswer) {
      return 0.0;
    }
    final correct = List<String>.from(q.answerKey['answers'] ?? []);
    final allOpts = List<String>.from(q.answerKey['options'] ?? []);
    if (correct.isEmpty || allOpts.isEmpty) return 0.0;
    final wrongOpts = allOpts.where((o) => !correct.contains(o)).toSet();
    final sel = a.selected.toSet();
    final good = sel.intersection(correct.toSet()).length;
    final bad = sel.intersection(wrongOpts).length;
    final sc = (good / correct.length) - (bad / wrongOpts.length.clamp(1, 999));
    return (q.points * sc.clamp(0.0, 1.0));
  }

  static String? correctAnswerString(QuizQuestion q) {
    return switch (q.type) {
      QuestionType.singleChoice => '${q.answerKey['answer'] ?? ''}',
      QuestionType.multiChoice =>
        (q.answerKey['answers'] as List?)?.join(', ') ?? '',
      QuestionType.trueFalse => q.answerKey['answer'] == true ? 'Vrai' : 'Faux',
      QuestionType.scale => 'Échelle 1-${q.answerKey['max'] ?? 5}',
      QuestionType.fillBlank || QuestionType.fillBlanks =>
        (q.answerKey['blanks'] as List?)
                ?.map((b) => '${(b as Map)['answer'] ?? ''}')
                .join('; ') ??
            '',
      QuestionType.cloze =>
        (q.answerKey['blanks'] as List?)
                ?.map((b) => '${(b as Map)['correct_answer'] ?? ''}')
                .join('; ') ??
            '',
      QuestionType.matching => ScoringV2Helpers.parseMatchingPairs(
        q.answerKey,
      ).entries.map((e) => '${e.key}→${e.value}').join(', '),
      QuestionType.shortAnswer => '(correction manuelle)',
    };
  }
}
