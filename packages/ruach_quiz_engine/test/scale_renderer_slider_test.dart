import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruach_quiz_engine/domain/quiz_answer.dart';
import 'package:ruach_quiz_engine/domain/quiz_question.dart';
import 'package:ruach_quiz_engine/presentation/renderers/scale_renderer.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

QuizQuestion _q(Map<String, dynamic> answerKey) =>
    QuizQuestion(id: 'x', type: QuestionType.scale, answerKey: answerKey);

void main() {
  testWidgets('display:slider -> rend un Slider, pas de pastilles', (t) async {
    await t.pumpWidget(_wrap(ScaleRenderer(
      question: _q({'min': 0, 'max': 100, 'step': 10, 'display': 'slider'}),
      onAnswer: (_) {},
    )));
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('50'), findsWidgets); // valeur par défaut = milieu
  });

  testWidgets('amplitude > 10 bascule aussi en Slider', (t) async {
    await t.pumpWidget(_wrap(ScaleRenderer(
      question: _q({'min': 0, 'max': 20}),
      onAnswer: (_) {},
    )));
    expect(find.byType(Slider), findsOneWidget);
  });

  testWidgets('Likert 1-5 garde les pastilles (non-régression)', (t) async {
    await t.pumpWidget(_wrap(ScaleRenderer(
      question: _q({'min': 1, 'max': 5}),
      onAnswer: (_) {},
    )));
    expect(find.byType(Slider), findsNothing);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('la valeur existante est reflétée par le Slider', (t) async {
    await t.pumpWidget(_wrap(ScaleRenderer(
      question: _q({'min': 0, 'max': 100, 'step': 10, 'display': 'slider'}),
      existingAnswer: const ScaleAnswer(questionId: 'x', selected: 80),
      onAnswer: (_) {},
    )));
    expect(t.widget<Slider>(find.byType(Slider)).value, 80);
  });

  testWidgets('glisser le Slider émet une ScaleAnswer arrondie', (t) async {
    QuizAnswer? emitted;
    await t.pumpWidget(_wrap(ScaleRenderer(
      question: _q({'min': 0, 'max': 100, 'step': 10, 'display': 'slider'}),
      onAnswer: (a) => emitted = a,
    )));
    await t.drag(find.byType(Slider), const Offset(200, 0));
    await t.pump();
    expect(emitted, isA<ScaleAnswer>());
    expect((emitted as ScaleAnswer).selected, greaterThan(50));
  });
}
