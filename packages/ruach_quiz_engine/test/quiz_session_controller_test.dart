import 'package:flutter_test/flutter_test.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

void main() {
  QuizDefinition buildQuiz() => QuizDefinition(
        id: 'quiz',
        title: 'Quiz',
        config: const QuizSessionConfig(timePerQuestionSeconds: 30),
        questions: const [
          QuizQuestion(
            id: 'q1',
            type: QuestionType.singleChoice,
            prompt: 'Q1',
            answerKey: {'options': ['A', 'B'], 'answer': 'A'},
          ),
          QuizQuestion(
            id: 'q2',
            type: QuestionType.trueFalse,
            prompt: 'Q2',
            answerKey: {'answer': true},
          ),
        ],
      );

  test('resumeSession restores answers, lock state and spent time', () async {
    final controller = QuizSessionController(definition: buildQuiz());
    await controller.resumeSession(
      currentIndex: 0,
      answers: const {
        'q1': SingleChoiceAnswer(questionId: 'q1', selected: 'A'),
      },
      spent: const {'q1': 12},
    );
    expect(controller.state, QuizSessionState.active);
    expect(controller.currentIndex, 0);
    expect(controller.locked, isTrue);
    expect(controller.selectedAnswer, isA<SingleChoiceAnswer>());
    expect(controller.timeSpentPerQuestion['q1'], 12);
  });

  test('resumeSession preserves skipped current question as locked', () async {
    final controller = QuizSessionController(definition: buildQuiz());
    await controller.resumeSession(
      currentIndex: 1,
      answers: const {},
      spent: const {'q2': 9},
      currentLocked: true,
    );

    expect(controller.currentIndex, 1);
    expect(controller.locked, isTrue);
    expect(controller.selectedAnswer, isNull);
    expect(controller.secondsLeft, 21);
  });

  test('snapshot keeps elapsed time for active question', () async {
    final controller = QuizSessionController(definition: buildQuiz())..start();

    await Future<void>.delayed(const Duration(milliseconds: 1100));
    final snapshot = controller.snapshot();

    expect(snapshot.currentIndex, 0);
    expect(snapshot.currentLocked, isFalse);
    expect(snapshot.spent['q1'], greaterThanOrEqualTo(1));
    controller.dispose();
  });

  test('resumeSession does not emit a second started event', () async {
    final analytics = _SpyAnalytics();
    final controller = QuizSessionController(
      definition: buildQuiz(),
      analytics: analytics,
    );

    await controller.resumeSession(
      currentIndex: 0,
      answers: const {},
      spent: const {},
    );

    expect(analytics.startedCount, 0);
  });

  test('editable mode lets a choice be replaced before next', () {
    final base = buildQuiz();
    final quiz = QuizDefinition(
      id: base.id,
      title: base.title,
      questions: base.questions,
      config: base.config.copyWith(editableUntilNext: true),
    );
    final controller = QuizSessionController(definition: quiz)..start();

    controller.answer(const SingleChoiceAnswer(questionId: 'q1', selected: 'A'));
    controller.answer(const SingleChoiceAnswer(questionId: 'q1', selected: 'B'));

    expect(controller.locked, isTrue);
    expect(
      (controller.selectedAnswer as SingleChoiceAnswer).selected,
      'B',
    );
  });

  test('Elo-lite ability rises after a correct answer, falls after a wrong one', () {
    final updates = <double>[];
    final controller = QuizSessionController(
      definition: buildQuiz(),
      onAbilityChanged: updates.add,
    )..start();

    expect(controller.ability, EloLite.defaultAbility);
    controller.answer(const SingleChoiceAnswer(questionId: 'q1', selected: 'A'));
    expect(controller.ability, greaterThan(EloLite.defaultAbility));
    expect(updates, [controller.ability]);

    controller.next();
    controller.answer(const TrueFalseAnswer(questionId: 'q2', selected: false));
    expect(controller.ability, lessThan(updates.first));
  });

  test('Elo-lite ability persists across a session via initialAbility', () {
    final controller = QuizSessionController(
      definition: buildQuiz(),
      initialAbility: 1200,
    )..start();

    expect(controller.ability, 1200);
  });

  QuizQuestion poolQuestion(String id, double difficulty) => QuizQuestion(
        id: id,
        type: QuestionType.trueFalse,
        prompt: id,
        answerKey: {'answer': true},
        difficultyLevel: difficulty,
      );

  QuizDefinition buildAdaptiveQuiz({int? questionsPerSession}) => QuizDefinition(
        id: 'adaptive-quiz',
        title: 'Adaptive',
        config: QuizSessionConfig(
          mode: QuizMode.adaptive,
          timePerQuestionSeconds: 30,
          questionsPerSession: questionsPerSession,
        ),
        questions: const [],
        questionsPool: [
          poolQuestion('easy', 800),
          poolQuestion('medium', 1000),
          poolQuestion('hard', 1200),
        ],
      );

  test('adaptive pool caps the session at questionsPerSession', () {
    final controller = QuizSessionController(
      definition: buildAdaptiveQuiz(questionsPerSession: 2),
      initialAbility: 1000,
    )..start();

    expect(controller.totalQuestions, 2);
    controller.answer(const TrueFalseAnswer(questionId: 'easy', selected: true));
  });

  test('adaptive pool never draws the same question twice', () {
    final controller = QuizSessionController(
      definition: buildAdaptiveQuiz(),
      initialAbility: 1000,
    )..start();

    final seen = <String>{controller.currentQuestion.id};
    while (controller.currentIndex + 1 < controller.totalQuestions) {
      controller.answer(
        TrueFalseAnswer(questionId: controller.currentQuestion.id, selected: true),
      );
      controller.next();
      expect(seen.add(controller.currentQuestion.id), isTrue,
          reason: 'question tirée deux fois dans la même session');
    }
    expect(seen.length, 3);
  });

  test('adaptive pool respects excludedQuestionIds (no-repeat-in-session)', () {
    final controller = QuizSessionController(
      definition: buildAdaptiveQuiz(),
      initialAbility: 1000,
      excludedQuestionIds: const {'easy', 'medium'},
    )..start();

    expect(controller.currentQuestion.id, 'hard');
    expect(controller.totalQuestions, 1);
  });

  test('standard (non-adaptive) quizzes are unaffected by the pool feature', () {
    final controller = QuizSessionController(definition: buildQuiz())..start();
    expect(controller.totalQuestions, 2);
    expect(controller.currentQuestion.id, 'q1');
  });

  test(
    'a standard quiz with questions misclassified into questionsPool still plays',
    () {
      final definition = QuizDefinition(
        id: 'misclassified',
        title: 'Misclassified',
        config: const QuizSessionConfig(timePerQuestionSeconds: 30),
        questions: const [],
        questionsPool: const [
          QuizQuestion(
            id: 'q1',
            type: QuestionType.trueFalse,
            prompt: 'Q1',
            answerKey: {'answer': true},
          ),
        ],
      );
      final controller = QuizSessionController(definition: definition)..start();
      expect(controller.hasCurrentQuestion, isTrue);
      expect(controller.currentQuestion.id, 'q1');
      expect(controller.totalQuestions, 1);
    },
  );

  test('hasCurrentQuestion is false before start() is called', () {
    final controller = QuizSessionController(definition: buildQuiz());
    expect(controller.hasCurrentQuestion, isFalse);
  });
}

class _SpyAnalytics implements QuizAnalyticsInterface {
  int startedCount = 0;

  @override
  void trackQuizStarted(String quizId, String title, int totalQuestions) {
    startedCount++;
  }

  @override
  void trackQuestionAnswered(
    String quizId,
    String questionId,
    QuestionType type,
    bool correct,
    int timeSeconds,
  ) {}

  @override
  void trackQuestionSkipped(String quizId, String questionId) {}

  @override
  void trackQuizCompleted(
    String quizId,
    double scorePercent,
    bool passed,
    int totalTimeSeconds,
    int correctCount,
    int totalQuestions,
  ) {}

  @override
  void trackQuizAbandoned(
    String quizId,
    int questionIndex,
    int elapsedSeconds,
  ) {}

  @override
  void trackImageLoadFailed(String quizId, String imageUrl) {}
}
