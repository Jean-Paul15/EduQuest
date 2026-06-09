import 'package:eduquest/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EduQuest app boots without widget errors', (WidgetTester tester) async {
    await tester.pumpWidget(const RuachEduApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MaterialApp), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);
  });
}
