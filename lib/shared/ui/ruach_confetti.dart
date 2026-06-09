import 'package:eduquest/shared/ui/confetti_painter.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

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
  final _particles = <ConfettiParticle>[];
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
      _particles.add(ConfettiParticle.random(_colors));
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
            painter: ConfettiPainter(_ctrl.value, List.unmodifiable(_particles)),
            size: Size.infinite,
          ),
        ),
      ],
    );
  }
}

bool _reduceMotion(BuildContext context) {
  return MediaQuery.of(context).accessibleNavigation;
}
