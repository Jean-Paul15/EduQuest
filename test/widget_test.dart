import 'package:eduquest/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EduQuest home renders key blocks', (WidgetTester tester) async {
    await tester.pumpWidget(const EduQuestApp());
    await tester.pumpAndSettle();

    expect(find.text('EduQuest'), findsOneWidget);
    expect(find.textContaining('Statut:'), findsOneWidget);
    expect(find.textContaining('Bienvenue'), findsOneWidget);
  });
}
