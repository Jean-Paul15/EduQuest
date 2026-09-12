import 'package:eduquest/shared/ui/widgets/ruach_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('anime en continu et se peint sans exception', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: RuachLoader(label: 'Chargement'))),
    ));
    expect(find.text('Chargement'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  });

  testWidgets('mouvement réduit : rendu figé, pas d’exception', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Scaffold(body: Center(child: RuachLoader())),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('Chargement en cours'), findsOneWidget);
  });
}
