import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_tap_scale.dart';

/// Tertiary text button — no border, gold text, 36dp height.
class RuachTextButton extends StatelessWidget {
  const RuachTextButton({super.key, required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      child: TapScale(
        child: TextButton(
          onPressed: onPressed ?? () {},
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 36),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RuachRadius.full)),
            foregroundColor: scheme.primary,
            disabledForegroundColor: scheme.primary,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
