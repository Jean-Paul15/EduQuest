import 'package:flutter_test/flutter_test.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

void main() {
  test('parses orientation mode with scale questions', () {
    final def = const QdlParser().parseFull({
      'quiz': {
        'id': 'orientation',
        'title': 'Orientation',
        'config': {
          'mode': 'orientation',
          'allow_skip': false,
          'editable_until_next': true,
        },
        'questions': [
          {
            'id': 'q1',
            'type': 'scale',
            'prompt': 'Question',
            'answer_key': {
              'min': 1,
              'max': 5,
              'axis_scores': {
                'I': {'5': 4},
              },
            },
          },
        ],
      },
    });
    expect(def.config.mode, QuizMode.orientation);
    expect(def.config.editableUntilNext, isTrue);
    expect(def.questions.single.type, QuestionType.scale);
  });

  test('scores axis scores for scale answers', () {
    final quiz = QuizDefinition(
      id: 'orientation',
      title: 'Orientation',
      config: const QuizSessionConfig(mode: QuizMode.orientation),
      questions: const [
        QuizQuestion(
          id: 'q1',
          type: QuestionType.scale,
          prompt: 'Question',
          answerKey: {
            'min': 1,
            'max': 5,
            'axis_scores': {
              'I': {'5': 4},
              'R': {'5': 2},
            },
          },
          points: 0,
        ),
      ],
    );
    final result = const ScoringEngine().score(
      quiz,
      quiz.questions,
      const {'q1': ScaleAnswer(questionId: 'q1', selected: 5)},
      const {'q1': 3},
    );
    expect(result.mode, QuizMode.orientation);
    expect(result.axisScores['I'], 4);
    expect(result.axisScores['R'], 2);
  });
}
