import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:eduquest/app/theme/ruach_theme.dart';

final _binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

Future<void> pumpTestApp(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: RuachTheme.light(),
      darkTheme: RuachTheme.dark(),
      home: child,
    ),
  );
  await tester.pumpAndSettle();
}

IntegrationTestWidgetsFlutterBinding get testBinding => _binding;
