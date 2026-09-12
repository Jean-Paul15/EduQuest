import 'package:eduquest/features/auth/presentation/signup_consent_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('legal and AI choices remain independent', (tester) async {
    var legal = false;
    var ai = false;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: SignupConsentCard(
              legalAccepted: legal,
              aiEnabled: ai,
              onLegalChanged: (v) => setState(() => legal = v),
              onAiChanged: (v) => setState(() => ai = v),
              onOpenTerms: () {},
              onOpenPrivacy: () {},
            ),
          ),
        ),
      ),
    );
    expect(find.byType(Checkbox), findsNWidgets(2));
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(legal, true);
    expect(ai, false);
  });
}
