import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_tap_scale.dart';
import 'package:flutter/material.dart';

class LearningTabChip extends StatelessWidget {
  const LearningTabChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        decoration: BoxDecoration(
          color: selected
              ? RuachColors.gold500
              : s.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(RuachRadius.full),
          border: Border.all(
            color: selected ? RuachColors.gold500 : s.outlineVariant,
          ),
          boxShadow: selected ? RuachShadows.buttonGlow : RuachShadows.none,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? RuachColors.white : s.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
