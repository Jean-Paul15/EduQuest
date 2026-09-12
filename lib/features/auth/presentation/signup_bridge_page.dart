import 'dart:async';
import 'package:eduquest/shared/sync/service_locator.dart';
import 'package:eduquest/shared/ui/widgets/ruach_progress.dart';
import 'package:flutter/material.dart';

class SignupBridgePage extends StatefulWidget {
  const SignupBridgePage({super.key});

  @override
  State<SignupBridgePage> createState() => _SignupBridgePageState();
}

class _SignupBridgePageState extends State<SignupBridgePage> {
  static const _messages = [
    'Préparation de ton espace RuachEdu…',
    'Activation de ton essai gratuit et de tes matières…',
  ];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_run());
  }

  Future<void> _run() async {
    final accessF = ServiceLocator().accessRepo.resolveAccess();
    await Future<void>.delayed(const Duration(seconds: 5));
    if (mounted) setState(() => _index = 1);
    await Future.wait([
      accessF,
      Future<void>.delayed(const Duration(seconds: 5)),
    ]);
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const RuachLoader(label: null, size: 92),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Text(
                _messages[_index],
                key: ValueKey(_index),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
