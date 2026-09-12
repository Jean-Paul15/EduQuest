import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_tap_scale.dart';

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
        child: FilledButton(
          onPressed: loading ? null : (onPressed ?? () {}),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RuachRadius.full)),
            backgroundColor: scheme.primary,
            disabledBackgroundColor: scheme.primary,
            foregroundColor: RuachColors.white,
            disabledForegroundColor: RuachColors.white,
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: loading
          ? const _ButtonLoader(key: ValueKey('loading'))
          : icon == null
          ? Text(label, key: const ValueKey('label'))
          : Row(
              key: const ValueKey('icon-label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: RuachSpace.s2),
                Text(label),
              ],
            ),
    );
  }
}

class _ButtonLoader extends StatefulWidget {
  const _ButtonLoader({super.key});

  @override
  State<_ButtonLoader> createState() => _ButtonLoaderState();
}

class _ButtonLoaderState extends State<_ButtonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 28,
    height: 20,
    child: AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final active = (_c.value + index * .2) % 1;
          return Container(
            width: 6,
            height: 6 + (active < .5 ? active * 6 : (1 - active) * 6),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              color: RuachColors.white,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    ),
  );
}
