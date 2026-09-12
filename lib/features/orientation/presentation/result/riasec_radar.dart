import 'dart:math' as math;

import 'package:eduquest/features/orientation/domain/riasec_profile.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

/// Hexagone RIASEC : 6 axes, tracé animé (coupé si `reduce motion`), et
/// alternative textuelle complète pour les lecteurs d'écran.
class RiasecRadar extends StatefulWidget {
  const RiasecRadar({super.key, required this.profile, this.size = 240});
  final RiasecProfile profile;
  final double size;

  @override
  State<RiasecRadar> createState() => _RiasecRadarState();
}

class _RiasecRadarState extends State<RiasecRadar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _ctrl.value = 1;
    } else if (!_ctrl.isAnimating && _ctrl.value == 0) {
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _a11y {
    final ranked = widget.profile.percents.entries.toList()
      ..sort((x, y) => y.value.compareTo(x.value));
    final parts = ranked
        .map((e) => '${RiasecProfile.labels[e.key]} ${e.value.round()}')
        .join(', ');
    return 'Profil RIASEC : $parts.';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _a11y,
      excludeSemantics: true,
      child: SizedBox(
        height: widget.size,
        child: CustomPaint(
          painter: _RadarPainter(widget.profile.percents, _ctrl),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter(this.scores, Animation<double> anim)
    : t = anim,
      super(repaint: anim);
  final Map<String, double> scores;
  final Animation<double> t;
  static const _labels = ['R', 'I', 'A', 'S', 'E', 'C'];

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) * .34;
    final grid = Paint()
      ..color = RuachColors.cream500.withAlpha(60)
      ..style = PaintingStyle.stroke;
    final fill = Paint()
      ..color = RuachColors.gold500.withAlpha(0x55)
      ..style = PaintingStyle.fill;
    final line = Paint()
      ..color = RuachColors.gold700
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var step = 1; step <= 4; step++) {
      canvas.drawPath(
        _path(c, r * (step / 4), {for (final l in _labels) l: 100}),
        grid,
      );
    }
    final animated = {
      for (final l in _labels) l: (scores[l] ?? 0) * t.value,
    };
    canvas.drawPath(_path(c, r, animated), fill);
    canvas.drawPath(_path(c, r, animated), line);

    for (var i = 0; i < _labels.length; i++) {
      final angle = (-math.pi / 2) + (2 * math.pi * i / _labels.length);
      final end = Offset(
        c.dx + math.cos(angle) * (r + 18),
        c.dy + math.sin(angle) * (r + 18),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: _labels[i],
          style: const TextStyle(
            color: RuachColors.gold700,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, end - Offset(tp.width / 2, tp.height / 2));
    }
  }

  Path _path(Offset c, double r, Map<String, num> values) {
    final path = Path();
    for (var i = 0; i < _labels.length; i++) {
      final angle = (-math.pi / 2) + (2 * math.pi * i / _labels.length);
      final radius = r * ((values[_labels[i]] ?? 0).clamp(0, 100) / 100);
      final p = Offset(
        c.dx + math.cos(angle) * radius,
        c.dy + math.sin(angle) * radius,
      );
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.scores != scores;
}
