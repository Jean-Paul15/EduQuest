import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class QcmOptionTile extends StatelessWidget {
  const QcmOptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.correct,
    required this.wrong,
    required this.locked,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool correct;
  final bool wrong;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: locked ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: correct
              ? RuachColors.success600.withValues(alpha: .08)
              : wrong
                  ? RuachColors.error400.withValues(alpha: .08)
                  : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(RuachRadius.md),
          border: Border.all(
            color: correct
                ? RuachColors.success600
                : wrong
                    ? RuachColors.error400
                    : selected
                        ? s.primary
                        : RuachColors.cream200,
            width: selected || correct || wrong ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: RuachColors.cream900,
          ),
        ),
      ),
    );
  }
}
