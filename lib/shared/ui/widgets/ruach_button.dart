import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/ruach_animations.dart';

/// Primary CTA button — pill-shaped, gold bg, dark text, 52dp height.
class RuachButton extends StatelessWidget {
  const RuachButton({
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
    final child = _RuachButtonContent(label: label, icon: icon, loading: loading);
    return Semantics(
      label: label,
      child: TapScale(
        onTap: onPressed,
        child: FilledButton(
          onPressed: null,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RuachRadius.full)),
            backgroundColor: scheme.primary,
            disabledBackgroundColor: scheme.primary,
            foregroundColor: RuachColors.ink100,
            disabledForegroundColor: RuachColors.ink100,
            textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, height: 20 / 14),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Content of primary button — adapts to loading state.
class _RuachButtonContent extends StatelessWidget {
  const _RuachButtonContent({required this.label, this.icon, required this.loading});
  final String label;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        width: 20, height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: RuachColors.ink100),
      );
    }
    if (icon == null) {
      return Text(label);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: RuachSpace.s2),
        Text(label),
      ],
    );
  }
}
