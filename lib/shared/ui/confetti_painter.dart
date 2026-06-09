import 'dart:math';

import 'package:flutter/material.dart';

Random particleRng() => Random(DateTime.now().microsecondsSinceEpoch % 1000000);

class ConfettiParticle {
  ConfettiParticle({required this.x, required this.dx, required this.dy, required this.color, required this.size, required this.rotation});
  final double x, dx, dy, size, rotation;
  final Color color;
  static ConfettiParticle random(List<Color> palette) {
    final rng = particleRng();
    return ConfettiParticle(
      x: rng.nextDouble() * 0.8 + 0.1,
      dx: rng.nextDouble() * 0.4 - 0.2,
      dy: rng.nextDouble() * 0.3 + 0.2,
      color: palette[rng.nextInt(palette.length)],
      size: rng.nextDouble() * 6 + 3,
      rotation: rng.nextDouble() * 3.14,
    );
  }
}

class ConfettiPainter extends CustomPainter {
  ConfettiPainter(this.progress, this.particles);
  final double progress;
  final List<ConfettiParticle> particles;

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
  bool shouldRepaint(covariant ConfettiPainter old) => old.progress != progress;
}
