import 'package:eduquest/features/auth/presentation/login_page.dart';
import 'package:eduquest/features/auth/presentation/register_steps_page.dart';
import 'package:eduquest/features/profile/data/profile_setup_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fake_auth_repository.dart';
import 'support/fake_class_selection_repository.dart';
import 'support/fake_profile_setup_repository.dart';
import 'support/test_data.dart';
import 'support/test_harness.dart';

void main() {
  testWidgets('auth:login-success submits valid credentials', (tester) async {
    final auth = FakeAuthRepository();
    await pumpTestApp(tester, LoginPage(repository: auth));
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'eleve@ruach.edu');
    await tester.enterText(fields.at(1), 'motdepasse123');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(auth.lastEmail, 'eleve@ruach.edu');
  });

  testWidgets('auth:register requires legal consent and finalizes profile', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    final profile = FakeProfileSetupRepository(
      const ProfileSetupState(
        fullName: '',
        levelId: null,
        seriesId: null,
        countryCode: 'TG',
        whatsappPhone: '',
        complete: false,
      ),
    );
    await pumpTestApp(
      tester,
      RegisterStepsPage(
        repository: auth,
        classRepo: FakeClassSelectionRepository(
          levels: testLevels,
          seriesByLevel: {'term': testSeries},
        ),
        profileSetup: profile,
      ),
    );
    await tester.enterText(find.byType(TextField).at(0), 'Kossi Doe');
    await tester.enterText(find.byType(TextField).at(1), '90123456');
    await tester.enterText(find.byType(TextField).at(2), 'Lycée test');
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'eleve@ruach.edu');
    await tester.enterText(find.byType(TextField).at(1), 'motdepasse123');
    await tester.enterText(find.byType(TextField).at(2), 'motdepasse123');
    await tester.tap(find.text('Créer mon compte'));
    await tester.pumpAndSettle();
    expect(profile.signupCompleted, false);
    expect(find.textContaining('Accepte les Conditions'), findsOneWidget);
    await tester.tap(find.byType(Checkbox).first);
    await tester.tap(find.text('Créer mon compte'));
    await tester.pumpAndSettle();
    expect(profile.signupCompleted, true);
    expect(profile.draftCleared, true);
  });
}
