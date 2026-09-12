import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/copy/app_copy.dart';
import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key, required this.register});

  final bool register;

  @override
  Widget build(BuildContext context) {
    final tx = Theme.of(context).textTheme;
    final s = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/ruachedu-logo-512.png',
          width: 64,
          height: 64,
        ),
        const SizedBox(height: RuachSpace.s5),
        Text(
          register ? AppCopy.createAccount : 'Bon retour',
          style: tx.headlineLarge,
        ),
        const SizedBox(height: RuachSpace.s1),
        Text(
          'Accès sécurisé RuachEdu',
          style: tx.titleMedium?.copyWith(color: s.onSurfaceVariant),
        ),
        const SizedBox(height: RuachSpace.s8),
      ],
    );
  }
}
