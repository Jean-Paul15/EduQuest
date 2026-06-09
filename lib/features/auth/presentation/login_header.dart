import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key, required this.register});

  final bool register;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final tx = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(RuachSpace.s3),
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
        const SizedBox(height: RuachSpace.s5),
        Text(
          register ? 'Creer un compte' : 'Bon retour',
          style: tx.headlineLarge,
        ),
        const SizedBox(height: RuachSpace.s1),
        Text(
          'Acces securise RuachEdu',
          style: tx.titleMedium?.copyWith(color: RuachColors.cream500),
        ),
        const SizedBox(height: RuachSpace.s8),
      ],
    );
  }
}
