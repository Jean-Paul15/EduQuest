import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class SignupConsentCard extends StatelessWidget {
  const SignupConsentCard({
    super.key,
    required this.legalAccepted,
    required this.aiEnabled,
    required this.onLegalChanged,
    required this.onAiChanged,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
  });

  final bool legalAccepted;
  final bool aiEnabled;
  final ValueChanged<bool> onLegalChanged;
  final ValueChanged<bool> onAiChanged;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(RuachSpace.s3),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(RuachRadius.lg),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: legalAccepted,
            onChanged: (v) => onLegalChanged(v ?? false),
            title: const Text(
              'J’accepte les Conditions d’utilisation et la Politique de confidentialité.',
              style: TextStyle(fontSize: 13, height: 1.35),
            ),
          ),
          Wrap(
            spacing: RuachSpace.s2,
            children: [
              TextButton(
                onPressed: onOpenTerms,
                child: const Text('Conditions d’utilisation'),
              ),
              TextButton(
                onPressed: onOpenPrivacy,
                child: const Text('Confidentialité'),
              ),
            ],
          ),
          const Divider(height: RuachSpace.s4),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: aiEnabled,
            onChanged: (v) => onAiChanged(v ?? false),
            title: const Text(
              'Personnalisation et amélioration IA',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Requis à la création pour activer l’expérience personnalisée RuachEdu.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: RuachSpace.s1),
          Text(
            'En continuant, tu confirmes ton inscription avec ces deux accords.',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
