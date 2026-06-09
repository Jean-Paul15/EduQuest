import 'package:eduquest/shared/ui/design_tokens.dart';
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: RuachMotion.tap,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? RuachColors.gold500 : RuachColors.white,
          borderRadius: BorderRadius.circular(RuachRadius.full),
          border: Border.all(
            color: selected ? RuachColors.gold500 : RuachColors.cream200,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? RuachColors.white : RuachColors.cream500,
          ),
        ),
      ),
    );
  }
}
