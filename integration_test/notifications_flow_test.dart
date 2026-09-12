import 'package:eduquest/features/notifications/data/user_notifications_repository.dart';
import 'package:eduquest/features/notifications/presentation/user_notifications_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fake_analytics.dart';
import 'support/fake_user_notifications_repository.dart';
import 'support/test_harness.dart';

void main() {
  testWidgets('notifications:list-and-open marks item as seen', (tester) async {
    final repo = FakeUserNotificationsRepository([
      UserNotificationItem(
        id: 'n1',
        title: 'Nouveau rappel',
        body: 'Révise les fonctions.',
        deeplink: '/learning',
        readAt: null,
        createdAt: DateTime(2026),
      ),
    ]);
    await pumpTestApp(
      tester,
      UserNotificationsPage(
        repository: repo,
        analytics: FakeAnalytics(),
      ),
    );
    expect(find.text('Nouveau rappel'), findsOneWidget);
    await tester.tap(find.text('Nouveau rappel'));
    await tester.pumpAndSettle();
    expect(repo.seenId, 'n1');
  });
}
