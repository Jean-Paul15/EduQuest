import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

class ContestDetailInfoRow extends StatelessWidget {
  const ContestDetailInfoRow({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: RuachSpace.s2),
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
          Expanded(child: Text(text, style: const TextStyle(color: RuachColors.cream500))),
        ],
      ),
    );
  }
}
