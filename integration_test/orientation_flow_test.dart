import 'package:eduquest/features/orientation/data/orientation_repository.dart';
import 'package:eduquest/features/orientation/presentation/orientation_page.dart';
import 'package:eduquest/features/user/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fake_offline_view_state.dart';
import 'support/fake_orientation_repository.dart';
import 'support/fake_user_profile_repository.dart';
import 'support/test_data.dart';
import 'support/test_harness.dart';

void main() {
  testWidgets('orientation:complete-online renders result', (tester) async {
    await pumpTestApp(
      tester,
      OrientationPage(
        repository: FakeOrientationRepository(definition: buildOrientationDefinition()),
        profileRepository: FakeUserProfileRepository(
          const UserProfile(displayName: 'Kossi', email: 'kossi@example.com', countryCode: 'TG', levelCode: 'Terminale', serieCode: 'D'),
        ),
        offlineState: FakeOfflineViewState(),
      ),
    );
    await tester.tap(find.text('Commencer le test'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5'));
    await tester.tap(find.text('Voir mon bilan'));
    await tester.pumpAndSettle();
    expect(find.text('IRA'), findsOneWidget);
    expect(find.textContaining('Bilan de test'), findsOneWidget);
    expect(find.textContaining('Informatique'), findsWidgets);
  });

  testWidgets('orientation:unavailable shows clear message', (tester) async {
    await pumpTestApp(
      tester,
      OrientationPage(
        repository: FakeOrientationRepository(
          definition: buildOrientationDefinition(),
          error: const OrientationUnavailable('L’orientation est indisponible pour le moment.'),
        ),
        profileRepository: FakeUserProfileRepository(
          const UserProfile(displayName: 'Kossi', email: 'kossi@example.com', countryCode: 'TG', levelCode: 'Terminale', serieCode: 'D'),
        ),
        offlineState: FakeOfflineViewState(),
      ),
    );
    expect(find.text('Orientation indisponible'), findsOneWidget);
    expect(find.textContaining('indisponible'), findsWidgets);
  });
}
