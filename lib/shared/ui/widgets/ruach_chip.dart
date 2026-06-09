import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_tap_scale.dart';

/// Category chip — 28dp height, 8dp radius.
class RuachChip extends StatelessWidget {
  const RuachChip({super.key, required this.label, this.selected = false, this.onTap});
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  static const _h = 28.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = selected ? RuachColors.gold500 : scheme.surfaceContainerHighest;
    final fg = selected ? RuachColors.ink100 : scheme.onSurfaceVariant;
    return TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: RuachSpace.s2),
        height: _h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(RuachRadius.sm),
          border: Border.all(color: selected ? RuachColors.gold500 : scheme.outline),
        ),
        child: Text(label, style: TextStyle(
          fontWeight: FontWeight.w500, fontSize: 11, height: 14 / 11,
          letterSpacing: 0.05 * 11, color: fg,
        )),
      ),
    );
  }
}
