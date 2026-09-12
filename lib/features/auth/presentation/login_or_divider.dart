import 'package:flutter/material.dart';

class LoginOrDivider extends StatelessWidget {
  const LoginOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou',
            style: TextStyle(
              color: s.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
