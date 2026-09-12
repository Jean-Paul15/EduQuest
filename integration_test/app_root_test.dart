import 'package:eduquest/app/testing/testable_app_root.dart';
import 'package:eduquest/features/profile/data/profile_setup_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fake_auth_repository.dart';
import 'support/fake_class_selection_repository.dart';
import 'support/fake_profile_setup_repository.dart';
import 'support/test_data.dart';
import 'support/test_harness.dart';

void main() {
  testWidgets('boot:first-launch shows onboarding then login', (tester) async {
    final root = TestableAppRoot(
      onboardingSeen: false,
      auth: FakeAuthRepository(),
      profileSetup: FakeProfileSetupRepository(
        const ProfileSetupState(fullName: '', levelId: null, seriesId: null, countryCode: 'TG', whatsappPhone: '', complete: false),
      ),
      classRepo: FakeClassSelectionRepository(levels: testLevels, seriesByLevel: {'term': testSeries}),
      pages: [for (final label in const ['Accueil', 'Assistant', 'Apprendre', 'Hub', 'Profil']) (_) => Center(child: Text(label))],
    );
    await pumpTestApp(tester, root);
    expect(find.text('Même sans\nconnexion'), findsOneWidget);
    await tester.tap(find.textContaining('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Bon retour'), findsOneWidget);
  });

  testWidgets('boot:main-nav-back-confirm shows exit dialog', (tester) async {
    await pumpTestApp(
      tester,
      TestableAppRoot(
        signedIn: true,
        profileComplete: true,
        auth: FakeAuthRepository(),
        profileSetup: FakeProfileSetupRepository(
          const ProfileSetupState(fullName: 'Kossi', levelId: 'term', seriesId: 'd', countryCode: 'TG', whatsappPhone: '90123456', complete: true),
        ),
        classRepo: FakeClassSelectionRepository(levels: testLevels, seriesByLevel: {'term': testSeries}),
        pages: [for (final label in const ['Accueil', 'Assistant', 'Apprendre', 'Hub', 'Profil']) (_) => Center(child: Text(label))],
      ),
    );
    testBinding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Quitter RuachEdu ?'), findsOneWidget);
    expect(find.text('Rester'), findsOneWidget);
  });
}
