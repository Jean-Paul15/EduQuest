import 'dart:math';

import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

/// Reusable animation utilities for RuachEdu.
/// All animations respect reduced-motion settings.

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

/// Staggered fade-in + slide-up builder for list items.
Widget staggerItem({required int index, required Widget child, Duration? baseDelay}) {
  return _StaggerItem(index: index, baseDelay: baseDelay ?? RuachMotion.staggerDelay, child: child);
}

class _StaggerItem extends StatefulWidget {
  const _StaggerItem({required this.index, required this.child, required this.baseDelay});
  final int index;
  final Widget child;
  final Duration baseDelay;
  @override
  State<_StaggerItem> createState() => _StaggerItemState();
}

class _StaggerItemState extends State<_StaggerItem> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    final reduce = _reduceMotion(context) == true;
    _ctrl = AnimationController(
      vsync: this,
      duration: reduce ? Duration.zero : RuachMotion.appear,
    );
    _opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: RuachCurves.appear),
    );
    _slide = Tween(begin: const Offset(0, 12), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: RuachCurves.appear),
    );
    Future.delayed(widget.baseDelay * widget.index, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, c) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(offset: _slide.value, child: c),
      ),
      child: widget.child,
    );
  }
}

/// Wraps a list of widgets with staggered fade-in.
List<Widget> staggerList(List<Widget> children, {Duration? baseDelay}) {
  return children.asMap().entries.map((e) =>
    staggerItem(index: e.key, child: e.value, baseDelay: baseDelay),
  ).toList();
}

/// Confetti-like overlay for celebration moments (lesson/quiz completed).
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key, required this.child, this.active = false});
  final Widget child;
  final bool active;
  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _particles = <_ConfettiParticle>[];
  bool _wasActive = false;

  static const _colors = [RuachColors.gold400, RuachColors.gold500, RuachColors.cream100, RuachColors.gold300, RuachColors.info400];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlay old) {
    super.didUpdateWidget(old);
    if (widget.active && !_wasActive) {
      _spawn();
    }
    _wasActive = widget.active;
  }

  void _spawn() {
    if (_reduceMotion(context) == true) return;
    _particles.clear();
    for (int i = 0; i < 20; i++) {
      _particles.add(_ConfettiParticle.random(_colors));
    }
    _ctrl.reset();
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _ConfettiPainter(_ctrl.value, List.unmodifiable(_particles)),
            size: Size.infinite,
          ),
        ),
      ],
    );
  }
}

class _ConfettiParticle {
  _ConfettiParticle({required this.x, required this.dx, required this.dy, required this.color, required this.size, required this.rotation});
  final double x, dx, dy, size, rotation;
  final Color color;
  static _ConfettiParticle random(List<Color> palette) {
    final rng = _rng();
    return _ConfettiParticle(
      x: rng.nextDouble() * 0.8 + 0.1,
      dx: rng.nextDouble() * 0.4 - 0.2,
      dy: rng.nextDouble() * 0.3 + 0.2,
      color: palette[rng.nextInt(palette.length)],
      size: rng.nextDouble() * 6 + 3,
      rotation: rng.nextDouble() * 3.14,
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.progress, this.particles);
  final double progress;
  final List<_ConfettiParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()..color = p.color.withValues(alpha: 1.0 - progress);
      final cx = size.width * (p.x + p.dx * progress);
      final cy = size.height * (-0.1 + p.dy * progress);
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(p.rotation * progress);
      canvas.drawRRect(RRect.fromLTRBR(0, 0, p.size, p.size * 0.5, const Radius.circular(2)), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.progress != progress;
}

Random _rng() => Random(DateTime.now().microsecondsSinceEpoch % 1000000);
