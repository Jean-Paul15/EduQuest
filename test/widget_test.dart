import 'package:eduquest/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EduQuest app boots without widget errors', (WidgetTester tester) async {
    await tester.pumpWidget(const EduQuestApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
