import 'package:eduquest/features/profile/data/profile_setup_repository.dart';
import 'package:eduquest/features/profile/presentation/profile_setup_gate_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fake_class_selection_repository.dart';
import 'support/fake_profile_setup_repository.dart';
import 'support/test_data.dart';
import 'support/test_harness.dart';

void main() {
  testWidgets('profile:gate-only-missing-fields asks only missing data', (
    tester,
  ) async {
    final repo = FakeProfileSetupRepository(
      const ProfileSetupState(
        fullName: 'Kossi Doe',
        levelId: 'term',
        seriesId: 'd',
        countryCode: 'TG',
        whatsappPhone: '',
        complete: false,
      ),
    );
    await pumpTestApp(
      tester,
      ProfileSetupGatePage(
        onDone: () {},
        repo: repo,
        classRepo: FakeClassSelectionRepository(
          levels: testLevels,
          seriesByLevel: {'term': testSeries},
          levelId: 'term',
          seriesId: 'd',
        ),
      ),
    );
    expect(find.text('Nom complet'), findsNothing);
    expect(find.text('Classe et série'), findsNothing);
    expect(find.text('Téléphone'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '90123456');
    await tester.tap(find.text('Finaliser mon profil'));
    await tester.pumpAndSettle();
    expect(repo.savedPhone, '90123456');
  });
}
