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
    this.loading = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      child: TapScale(
        child: OutlinedButton(
          onPressed: loading ? null : (onPressed ?? () {}),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RuachRadius.full)),
            side: BorderSide(color: scheme.primary, width: 1.5),
            foregroundColor: scheme.primary,
            disabledForegroundColor: scheme.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, height: 16 / 12),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: loading
                ? SizedBox(
                    key: const ValueKey('loading'),
                    width: 22,
                    height: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: .9 - (i * .18)),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  )
                : icon != null
                ? Row(
                    key: const ValueKey('icon-label'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 20),
                      const SizedBox(width: RuachSpace.s2),
                      Text(label),
                    ],
                  )
                : Text(label, key: const ValueKey('label')),
          ),
        ),
      ),
    );
  }
}
