import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IntroBottomSection extends StatelessWidget {
  const IntroBottomSection({
    super.key,
    required this.legalLoading,
    required this.isSubmitting,
    required this.hasNext,
    required this.onContinuePressed,
    required this.onSkip,
  });

  final bool legalLoading;
  final bool isSubmitting;
  final bool hasNext;
  final VoidCallback onContinuePressed;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Column(
      children: [
        // Toujours proposer une sortie explicite du tunnel d'onboarding
        // (bonne pratique quasi unanime) — masqué sur le dernier slide où
        // il ferait doublon avec le CTA "Commencer".
        if (hasNext)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: isSubmitting ? null : onSkip,
              child: const Text('Passer'),
            ),
          ),
        Text(
          'En continuant, tu acceptes nos conditions et notre politique de confidentialité.',
          textAlign: TextAlign.center,
          style: TextStyle(color: s.onSurfaceVariant, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: legalLoading
                  ? null
                  : () => context.pushNamed(AppRoutes.legal, pathParameters: {'docType': 'terms'}),
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Conditions'),
            ),
            TextButton(
              onPressed: legalLoading
                  ? null
                  : () => context.pushNamed(AppRoutes.legal, pathParameters: {'docType': 'privacy'}),
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Confidentialité'),
            ),
            if (legalLoading)
              const Padding(
                padding: EdgeInsets.only(left: RuachSpace.s1),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: RuachButton(
            label: hasNext ? 'Poursuivre' : 'Commencer',
            onPressed: isSubmitting ? null : onContinuePressed,
            loading: isSubmitting,
          ),
        ),
      ],
    );
  }
}
