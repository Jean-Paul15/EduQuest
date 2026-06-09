import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key, required this.register});

  final bool register;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: s.primary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(RuachRadius.sm),
          ),
          child: Icon(
            PhosphorIconsRegular.graduationCap,
            color: s.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          register ? 'Creer un compte' : 'Bon retour',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: RuachColors.cream900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Acces securise RuachNova',
          style: TextStyle(
            color: RuachColors.cream500,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}
