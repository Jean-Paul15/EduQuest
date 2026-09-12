import 'package:flutter_test/flutter_test.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

void main() {
  group('QdlParser', () {
    late QdlParser parser;
    setUp(() => parser = const QdlParser());

    test('parse legacy single_choice questions', () {
      final rows = [
        {
          'id': 'q1',
          'type': 'mcq',
          'prompt': 'Capitale du Togo ?',
          'options': ['Lome', 'Kara', 'Sokode', 'Atakpame'],
          'answer': 'Lome',
        },
      ];
      final def = parser.parseQuestions(
        quizId: 'quiz-1',
        title: 'Test',
        rows: rows,
      );
      expect(def.totalQuestions, 1);
      expect(def.questions.first.type, QuestionType.singleChoice);
      expect(def.questions.first.prompt, 'Capitale du Togo ?');
      expect(def.questions.first.answerKey['options'], hasLength(4));
      expect(def.questions.first.answerKey['answer'], 'Lome');
    });

    test('parse full QDL format', () {
      final raw = {
        'version': 1,
        'quiz': {
          'id': 'q1',
          'title': 'Maths',
          'config': {'time_per_question_seconds': 20, 'shuffle_options': false},
          'questions': [
            {
              'id': 'q1',
              'type': 'single_choice',
              'prompt': '2+2=?',
              'answer_key': {'options': ['3', '4'], 'answer': '4'},
              'explanation': [
                {'type': 'text', 'value': 'Addition simple.'},
              ],
              'points': 2,
            }
          ],
        },
      };
      final def = parser.parseFull(raw);
      expect(def.id, 'q1');
      expect(def.config.timePerQuestionSeconds, 20);
      expect(def.config.shuffleOptions, false);
      expect(def.questions.first.points, 2);
      expect(def.questions.first.explanation, hasLength(1));
      expect((def.questions.first.explanation.first as TextBlock).value,
          'Addition simple.');
    });

    test('parse legacy explanation string as rich text block', () {
      final rows = [
        {
          'id': 'q1',
          'type': 'mcq',
          'prompt': 'Capitale du Togo ?',
          'options': ['Lome', 'Kara'],
          'answer': 'Lome',
          'explanation': 'Lome est la capitale.',
        },
      ];
      final def = parser.parseQuestions(
        quizId: 'quiz-1',
        title: 'Test',
        rows: rows,
      );
      expect(def.questions.first.explanation, hasLength(1));
      expect((def.questions.first.explanation.first as TextBlock).value,
          'Lome est la capitale.');
    });
  });
}
