import 'package:flutter_test/flutter_test.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

void main() {
  test('round-trips V1 and V2 answers in a session snapshot', () {
    final snapshot = QuizSessionSnapshot(
      currentIndex: 3,
      answers: {
        'q1': const SingleChoiceAnswer(questionId: 'q1', selected: 'A'),
        'q2': const FillBlanksAnswer(
          questionId: 'q2',
          answers: {1: 'alpha', 2: 'beta'},
        ),
        'q3': const MatchingAnswer(
          questionId: 'q3',
          pairs: {'left-1': 'right-2'},
        ),
      },
      spent: const {'q1': 4, 'q2': 11, 'q3': 7},
      currentLocked: true,
    );

    final restored = QuizSessionSnapshot.fromMap(snapshot.toMap())!;

    expect(restored.currentIndex, 3);
    expect(restored.currentLocked, isTrue);
    expect(restored.spent['q2'], 11);
    expect(restored.answers['q1'], isA<SingleChoiceAnswer>());
    expect((restored.answers['q2'] as FillBlanksAnswer).answers[2], 'beta');
    expect(
      (restored.answers['q3'] as MatchingAnswer).pairs['left-1'],
      'right-2',
    );
  });

  test(
    'controller resumes from package snapshot without losing state',
    () async {
      final quiz = QuizDefinition(
        id: 'quiz',
        title: 'Quiz',
        questions: const [
          QuizQuestion(
            id: 'q1',
            type: QuestionType.singleChoice,
            prompt: '?',
            answerKey: {
              'options': ['A', 'B'],
              'answer': 'A',
            },
          ),
          QuizQuestion(
            id: 'q2',
            type: QuestionType.shortAnswer,
            prompt: '?',
            answerKey: {'answer': 'Libre'},
          ),
        ],
      );
      final controller = QuizSessionController(definition: quiz)..start();

      await controller.resumeFromSnapshot(
        const QuizSessionSnapshot(
          currentIndex: 1,
          answers: {'q1': SingleChoiceAnswer(questionId: 'q1', selected: 'A')},
          spent: {'q1': 6},
          currentLocked: false,
        ),
      );

      expect(controller.currentIndex, 1);
      expect(controller.answers['q1'], isA<SingleChoiceAnswer>());
      expect(controller.state, QuizSessionState.active);
      expect(controller.locked, false);
    },
  );
}
