import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruach_quiz_engine/domain/quiz_answer.dart';
import 'package:ruach_quiz_engine/domain/quiz_question.dart';
import 'package:ruach_quiz_engine/presentation/renderers/fill_blank_body.dart';
import 'package:ruach_quiz_engine/presentation/renderers/matching_body.dart';
import 'package:ruach_quiz_engine/presentation/widgets/option_picker_sheet.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('fill blank commits only on validation', (tester) async {
    QuizAnswer? emitted;
    const question = QuizQuestion(
      id: 'q1',
      type: QuestionType.fillBlank,
      answerKey: {'text': 'Paris est la capitale de ___', 'blanks': [{'position': 1, 'answer': 'France'}]},
    );
    await tester.pumpWidget(_wrap(FillBlankBody(
      question: question, locked: false, existingAnswer: null, onAnswer: (a) => emitted = a,
    )));
    await tester.enterText(find.byType(TextField), 'France');
    await tester.pump();
    expect(emitted, isNull);
    await tester.tap(find.text('Valider'));
    await tester.pump();
    expect((emitted as FillBlankAnswer).answers[1], 'France');
  });

  testWidgets('matching commits only after all pairs are validated', (tester) async {
    QuizAnswer? emitted;
    const question = QuizQuestion(
      id: 'q2',
      type: QuestionType.matching,
      answerKey: {
        'left_items': [{'id': 'l1', 'label': 'Chat'}, {'id': 'l2', 'label': 'Chien'}],
        'right_items': [{'id': 'r1', 'label': 'Miaule'}, {'id': 'r2', 'label': 'Aboie'}],
      },
    );
    await tester.pumpWidget(_wrap(MatchingBody(
      question: question, locked: false, existingAnswer: null, onAnswer: (a) => emitted = a,
    )));
    await tester.tap(find.byType(OptionPickerField).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Miaule'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OptionPickerField).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aboie'));
    await tester.pumpAndSettle();
    expect(emitted, isNull);
    await tester.tap(find.text('Valider les associations'));
    await tester.pump();
    expect((emitted as MatchingAnswer).pairs, {'l1': 'r1', 'l2': 'r2'});
  });
}
