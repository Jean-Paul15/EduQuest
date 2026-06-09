import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_tap_scale.dart';

/// Secondary outlined button — transparent bg, gold border, 44dp height.
class RuachOutlineButton extends StatelessWidget {
  const RuachOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      child: TapScale(
        child: OutlinedButton(
          onPressed: onPressed ?? () {},
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RuachRadius.full)),
            side: BorderSide(color: scheme.primary, width: 1.5),
            foregroundColor: scheme.primary,
            disabledForegroundColor: scheme.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, height: 16 / 12),
          ),
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: RuachSpace.s2),
                    Text(label),
                  ],
                )
              : Text(label),
        ),
      ),
    );
  }
}
