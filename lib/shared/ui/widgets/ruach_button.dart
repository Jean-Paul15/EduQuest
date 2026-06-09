import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

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
    return _AnimatedTap(
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RuachRadius.full)),
          backgroundColor: scheme.primary,
          foregroundColor: RuachColors.ink100,
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, height: 20 / 14),
        ),
        child: child,
      ),
    );
  }
}

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
    return _AnimatedTap(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RuachRadius.full)),
          side: BorderSide(color: scheme.primary, width: 1.5),
          foregroundColor: scheme.primary,
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
    );
  }
}

/// Tertiary text button — no border, gold text, 36dp height.
class RuachTextButton extends StatelessWidget {
  const RuachTextButton({super.key, required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RuachRadius.full)),
        foregroundColor: scheme.primary,
      ),
      child: Text(label),
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

/// Tap animation: scale 0.96, 100ms easeOut.
class _AnimatedTap extends StatefulWidget {
  const _AnimatedTap({required this.child});
  final Widget child;
  @override
  State<_AnimatedTap> createState() => _AnimatedTapState();
}

class _AnimatedTapState extends State<_AnimatedTap> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _ctrl.forward(),
      onPointerUp: (_) => _ctrl.reverse(),
      onPointerCancel: (_) => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
