import 'package:flutter_test/flutter_test.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

void main() {
  group('ScoringEngine', () {
    late ScoringEngine engine;
    setUp(() => engine = const ScoringEngine());

    QuizDefinition simpleQuiz(QuestionType type, Map<String, dynamic> key) {
      final q = QuizQuestion(id: 'q1', type: type, prompt: '?', answerKey: key);
      return QuizDefinition(id: 'qz', title: 'T', questions: [q]);
    }

    test('single_choice correct answer scores 1', () {
      final quiz = simpleQuiz(QuestionType.singleChoice, {
        'options': ['A', 'B'], 'answer': 'A',
      });
      final answers = <String, QuizAnswer>{
        'q1': SingleChoiceAnswer(questionId: 'q1', selected: 'A'),
      };
      final r = engine.score(quiz, quiz.questions, answers, {'q1': 10});
      expect(r.correctCount, 1);
      expect(r.wrongCount, 0);
      expect(r.earnedPoints, 1.0);
    });

    test('single_choice wrong answer scores 0', () {
      final quiz = simpleQuiz(QuestionType.singleChoice, {
        'options': ['A', 'B'], 'answer': 'A',
      });
      final answers = <String, QuizAnswer>{
        'q1': SingleChoiceAnswer(questionId: 'q1', selected: 'B'),
      };
      final r = engine.score(quiz, quiz.questions, answers, {'q1': 10});
      expect(r.correctCount, 0);
      expect(r.wrongCount, 1);
      expect(r.earnedPoints, 0.0);
    });

    test('true_false correct', () {
      final quiz = simpleQuiz(QuestionType.trueFalse, {'answer': true});
      final answers = <String, QuizAnswer>{
        'q1': TrueFalseAnswer(questionId: 'q1', selected: true),
      };
      final r = engine.score(quiz, quiz.questions, answers, {'q1': 5});
      expect(r.correctCount, 1);
    });

    test('fill_blank exact match', () {
      final quiz = simpleQuiz(QuestionType.fillBlank, {
        'text': 'Le ___ est grand.',
        'blanks': [{'position': 1, 'answer': 'mont'}],
      });
      final answers = <String, QuizAnswer>{
        'q1': FillBlankAnswer(questionId: 'q1', answers: {1: 'mont'}),
      };
      final r = engine.score(quiz, quiz.questions, answers, {'q1': 8});
      expect(r.correctCount, 1);
    });

    test('fill_blank case-insensitive match', () {
      final quiz = simpleQuiz(QuestionType.fillBlank, {
        'text': 'Le ___ est grand.',
        'blanks': [{'position': 1, 'answer': 'Mont'}],
      });
      final answers = <String, QuizAnswer>{
        'q1': FillBlankAnswer(questionId: 'q1', answers: {1: 'MONT'}),
      };
      final r = engine.score(quiz, quiz.questions, answers, {'q1': 8});
      expect(r.correctCount, 1);
    });

    test('skipped question counts as skipped', () {
      final quiz = simpleQuiz(QuestionType.singleChoice, {
        'options': ['A', 'B'], 'answer': 'A',
      });
      final r = engine.score(quiz, quiz.questions, {}, {'q1': 0});
      expect(r.skippedCount, 1);
      expect(r.earnedPoints, 0.0);
    });

    test('scorePercent calculated correctly', () {
      final qs = [
        QuizQuestion(id: '1', type: QuestionType.singleChoice, prompt: '?',
            answerKey: {'options': ['A','B'], 'answer': 'A'}),
        QuizQuestion(id: '2', type: QuestionType.singleChoice, prompt: '?',
            answerKey: {'options': ['C','D'], 'answer': 'C'}),
      ];
      final quiz = QuizDefinition(id: 'qz', title: 'T', questions: qs);
      final answers = <String, QuizAnswer>{
        '1': SingleChoiceAnswer(questionId: '1', selected: 'A'),
        '2': SingleChoiceAnswer(questionId: '2', selected: 'D'),
      };
      final r = engine.score(quiz, quiz.questions, answers, {'1': 5, '2': 7});
      expect(r.scorePercent, 50.0);
      expect(r.totalTimeSeconds, 12);
    });
  });
}
