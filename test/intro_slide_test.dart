import 'package:eduquest/features/onboarding/presentation/intro_slide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpAt(WidgetTester tester, Size size, int itemIndex) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final item = introItems[itemIndex];
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: IntroSlide(
          title: item.$1,
          description: item.$2,
          icon: item.$3,
          imagePath: item.$4,
        ),
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  for (var i = 0; i < introItems.length; i++) {
    testWidgets('slide $i has no RenderFlex overflow on a wide short viewport',
        (tester) async {
      // Reproduit la taille exacte (1038.4x524.6) où l'ancien AspectRatio(4/5)
      // débordait de 929px.
      await _pumpAt(tester, const Size(1038, 525), i);
      expect(tester.takeException(), isNull);
    });

    testWidgets('slide $i has no RenderFlex overflow on a narrow phone viewport',
        (tester) async {
      await _pumpAt(tester, const Size(375, 812), i);
      expect(tester.takeException(), isNull);
    });
  }
}
