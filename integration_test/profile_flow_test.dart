import 'package:eduquest/features/class_selection/presentation/class_selection_panel.dart';
import 'package:eduquest/features/profile/presentation/widgets/whatsapp_phone_card.dart';
import 'package:eduquest/features/user/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fake_class_selection_repository.dart';
import 'support/fake_user_profile_repository.dart';
import 'support/test_data.dart';
import 'support/test_harness.dart';

void main() {
  testWidgets('profile:update-phone-and-class persists selections', (
    tester,
  ) async {
    final userRepo = FakeUserProfileRepository(
      const UserProfile(
        displayName: 'Kossi',
        email: 'kossi@example.com',
        countryCode: 'TG',
        levelCode: 'Terminale',
        serieCode: 'D',
        whatsappPhone: '90123456',
      ),
    );
    final classRepo = FakeClassSelectionRepository(
      levels: testLevels,
      seriesByLevel: {'term': testSeries},
      levelId: 'term',
      seriesId: 'd',
    );
    await pumpTestApp(
      tester,
      Column(
        children: [
          WhatsAppPhoneCard(
            countryCode: 'TG',
            phone: '90123456',
            onPhoneChanged: () {},
            repository: userRepo,
          ),
          ClassSelectionPanel(repository: classRepo),
        ],
      ),
    );
    await tester.enterText(find.byType(TextField).first, '90112233');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(userRepo.lastPhone, '90112233');
    await tester.tap(find.text('Appliquer'));
    await tester.pumpAndSettle();
    expect((await classRepo.current())['seriesId'], 'd');
  });
}
