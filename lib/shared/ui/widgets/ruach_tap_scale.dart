import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

/// Returns true when the OS reduce-motion setting is active.
bool _reduceMotion(BuildContext context) {
  return MediaQuery.of(context).accessibleNavigation;
}

/// Scale-down tap animation (0.96, 100ms easeOut).
/// Automatically skips animation when reduceMotion is on.
class TapScale extends StatefulWidget {
  const TapScale({super.key, required this.child, this.onTap, this.scale = 0.96});
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  bool _reduce = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: RuachMotion.tap);
    _anim = Tween(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _ctrl, curve: RuachCurves.tap),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _down(_) { _reduce = _reduceMotion(context) == true; if (!_reduce) _ctrl.forward(); }
  void _up(_) { if (_reduce) { widget.onTap?.call(); } else { _ctrl.reverse().then((_) => widget.onTap?.call()); } }
  void _cancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down, onTapUp: _up, onTapCancel: _cancel,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, c) => Transform.scale(scale: _anim.value, child: c),
        child: widget.child,
      ),
    );
  }
}
