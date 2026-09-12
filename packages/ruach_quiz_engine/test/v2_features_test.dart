import 'package:flutter_test/flutter_test.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

void main() {
  test('parses V2 content blocks and groups', () {
    final def = const QdlParser().parseFull({
      'version': 2,
      'quiz': {
        'id': 'quiz-v2',
        'title': 'Maths',
        'groups': [
          {
            'id': 'g1',
            'group_title': 'Contexte partagé',
            'shared_context': [
              {'type': 'text', 'value': 'Lis bien le contexte.'},
            ],
          },
        ],
        'questions': [
          {
            'id': 'q1',
            'type': 'cloze',
            'group_id': 'g1',
            'statement': [
              {'type': 'text', 'value': 'Résous '},
              {'type': 'latex_inline', 'formula': 'x^2=4'},
            ],
            'answer_key': {
              'blanks': [
                {'blank_id': 1, 'answer': '2'},
              ],
            },
          },
        ],
      },
    });

    expect(def.groups, hasLength(1));
    expect(def.groupFor('q1')?.title, 'Contexte partagé');
    expect(def.questions.first.type, QuestionType.cloze);
    expect(def.questions.first.statement.whereType<LatexBlock>(), hasLength(1));
  });

  test('scores matching with partial credit in V2', () {
    final quiz = QuizDefinition(
      id: 'quiz-v2',
      title: 'Associe',
      questions: const [
        QuizQuestion(
          id: 'q1',
          type: QuestionType.matching,
          prompt: 'Associe',
          answerKey: {
            'correct_pairs': {'A': '1', 'B': '2'},
          },
          points: 2,
        ),
      ],
      config: const QuizSessionConfig(partialCredit: true),
    );

    final result = const ScoringEngine().score(
      quiz,
      quiz.questions,
      {
        'q1': const MatchingAnswer(
          questionId: 'q1',
          pairs: {'A': '1', 'B': '9'},
        ),
      },
      const {'q1': 9},
    );

    expect(result.wrongCount, 1);
    expect(result.earnedPoints, 1);
  });
}
