import 'dart:math' as math;

import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

/// Chargeur « atome » : arc qui balaie vite (repere « ca tourne »), 3 orbites
/// qui tumblent, un electron par orbite avec longue trainee, onde qui se propage
/// depuis le noyau qui pulse, et des etincelles qui derivent vers l'exterieur.
/// Mouvement franc et permanent pour une vraie sensation d'activite. Palette RuachEdu.
class AtomLoaderPainter extends CustomPainter {
  const AtomLoaderPainter({required this.t, required this.dark, required this.reduceMotion});

  final double t; // phase d'animation 0..1
  final bool dark;
  final bool reduceMotion;

  static const _speeds = [1.7, -2.5, 3.3];
  static const _phases = [0.0, 2.1, 4.2];
  static const _tumble = [0.08, -0.13, 0.19];

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final a = r * 0.9, b = r * 0.36;
    final glow = dark ? 0.42 : 0.30;

    // Arc de balayage : lecture immediate « chargement en cours ».
    canvas
      ..save()
      ..translate(c.dx, c.dy)
      ..rotate(t * 2 * math.pi * 1.6);
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r * 0.86),
      0,
      math.pi * 1.15,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = r * 0.06
        ..shader = SweepGradient(
          endAngle: math.pi * 1.15,
          colors: [RuachColors.gold500.withValues(alpha: 0), RuachColors.gold500],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r * 0.86)),
    );
    canvas.restore();

    // Onde qui se propage depuis le noyau.
    final ping = t % 1.0;
    canvas.drawCircle(
      c,
      r * (0.14 + 0.82 * ping),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.022
        ..color = RuachColors.gold400.withValues(alpha: 0.4 * (1 - ping)),
    );

    // 3 orbites qui tumblent + electron + trainee.
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, r * 0.03)
      ..color = RuachColors.gold400.withValues(alpha: glow);
    for (var i = 0; i < 3; i++) {
      canvas
        ..save()
        ..translate(c.dx, c.dy)
        ..rotate(i * math.pi / 3 + t * 2 * math.pi * _tumble[i]);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: a * 2, height: b * 2), orbitPaint);
      final ang = 2 * math.pi * (t * _speeds[i]) + _phases[i];
      final dir = _speeds[i].isNegative ? -1.0 : 1.0;
      for (var k = 7; k >= 1; k--) {
        final ta = ang - k * 0.13 * dir;
        canvas.drawCircle(
          Offset(math.cos(ta) * a, math.sin(ta) * b),
          r * 0.07 * (1 - k * 0.11),
          Paint()..color = RuachColors.gold500.withValues(alpha: 0.11 * (8 - k) / 7),
        );
      }
      final e = Offset(math.cos(ang) * a, math.sin(ang) * b);
      canvas
        ..drawCircle(e, r * 0.17, Paint()..color = RuachColors.gold500.withValues(alpha: 0.2))
        ..drawCircle(e, r * 0.09, Paint()..color = RuachColors.gold500)
        ..restore();
    }

    // Etincelles qui derivent vers l'exterieur.
    for (var i = 0; i < 10; i++) {
      final base = i / 10;
      final ph = (t * 1.3 + base) % 1.0;
      final an = base * 2 * math.pi + t * 2 * math.pi * 0.5;
      final o = c + Offset(math.cos(an), math.sin(an)) * (r * (0.2 + 0.78 * ph));
      canvas.drawCircle(o, r * 0.032,
          Paint()..color = RuachColors.gold300.withValues(alpha: 0.4 * math.sin(ph * math.pi)));
    }

    // Noyau qui pulse.
    final pulse = reduceMotion ? 1.0 : 0.82 + 0.22 * math.sin(t * 2 * math.pi);
    canvas
      ..drawCircle(c, r * 0.26 * pulse, Paint()..color = RuachColors.gold500.withValues(alpha: 0.18))
      ..drawCircle(c, r * 0.13 * pulse, Paint()..color = RuachColors.gold600);
  }

  @override
  bool shouldRepaint(AtomLoaderPainter old) =>
      old.t != t || old.dark != dark || old.reduceMotion != reduceMotion;
}
