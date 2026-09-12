import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

/// Ligne icône + texte partagée par les détails concours et événements — fusion de
/// ContestDetailInfoRow et EventInfoRow (implémentations quasi identiques, dupliquées).
class EngagementInfoRow extends StatelessWidget {
  const EngagementInfoRow({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RuachSpace.s1),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(RuachSpace.s2),
            decoration: BoxDecoration(
              color: s.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(RuachRadius.sm),
            ),
            child: Icon(icon, size: 18, color: s.primary),
          ),
          const SizedBox(width: RuachSpace.s3),
          Expanded(child: Text(text, style: TextStyle(color: s.onSurfaceVariant))),
        ],
      ),
    );
  }
}
