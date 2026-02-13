import 'package:eduquest/shared/security/sensitive_guard.dart';
import 'package:flutter/widgets.dart';

class SensitiveScope extends StatefulWidget {
  const SensitiveScope({super.key, required this.child});
  final Widget child;

  @override
  State<SensitiveScope> createState() => _SensitiveScopeState();
}

class _SensitiveScopeState extends State<SensitiveScope> {
  @override
  void initState() {
    super.initState();
    SensitiveGuard.enable();
  }

  @override
  void dispose() {
    SensitiveGuard.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

