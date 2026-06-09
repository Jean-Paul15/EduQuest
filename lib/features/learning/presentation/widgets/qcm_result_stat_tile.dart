import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class QcmResultStatTile extends StatelessWidget {
  const QcmResultStatTile({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: RuachColors.cream50,
        borderRadius: BorderRadius.circular(RuachRadius.md),
        border: Border.all(color: RuachColors.cream200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: RuachColors.cream500,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: RuachColors.cream900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
