import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

class EventInfoRow extends StatelessWidget {
  const EventInfoRow({
    super.key,
    required this.icon,
    required this.text,
    required this.colorScheme,
  });

  final IconData icon;
  final String text;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: RuachSpace.s2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(RuachSpace.s2),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(RuachRadius.sm),
            ),
            child: Icon(icon, size: 18, color: colorScheme.primary),
          ),
          const SizedBox(width: RuachSpace.s3),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: RuachColors.cream500),
            ),
          ),
        ],
      ),
    );
  }
}
