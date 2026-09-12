import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

/// Petit badge du motif de recommandation ("À réviser" / "À renforcer") sous
/// le titre d'une carte `ReviewSectionPage`. Toujours une formulation positive
/// (jamais "tu as régressé") même quand la maîtrise a décru avec le temps.
class ReviewReasonPill extends StatelessWidget {
  const ReviewReasonPill({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: RuachColors.gold500.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(RuachRadius.full),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: RuachColors.gold600,
        ),
      ),
    );
  }
}
