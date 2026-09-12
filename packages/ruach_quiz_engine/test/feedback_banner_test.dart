import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruach_quiz_engine/presentation/widgets/feedback_banner.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

void main() {
  testWidgets('renders rich explanation blocks in feedback banner',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FeedbackBanner(
            correct: false,
            explanation: [
              TextBlock('Relis la règle.'),
              CalloutBlock(content: [TextBlock('Indice utile')]),
            ],
            showAnswer: true,
            correctAnswer: 'Lomé',
          ),
        ),
      ),
    );

    expect(find.text('Incorrect'), findsOneWidget);
    expect(find.text('Relis la règle.'), findsOneWidget);
    expect(find.text('Indice utile'), findsOneWidget);
    expect(find.text('Réponse : Lomé'), findsOneWidget);
  });
}
