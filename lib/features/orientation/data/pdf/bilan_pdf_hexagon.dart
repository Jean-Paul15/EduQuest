import 'dart:math' as math;

import 'package:eduquest/features/orientation/data/pdf/bilan_pdf_theme.dart';
import 'package:eduquest/features/orientation/domain/riasec_profile.dart';
import 'package:pdf/pdf.dart';

/// Direction du sommet `i` de l'hexagone RIASEC (R en haut, sens horaire).
double hexAngle(int i) => (-math.pi / 2) + (2 * math.pi * i / 6);

/// Tracé vectoriel de l'hexagone : 4 anneaux de repère, 6 rayons, polygone
/// de valeurs rempli puis contouré. Couleurs du design system RuachEdu.
void paintRiasecHexagon(PdfGraphics canvas, PdfPoint size, Map<String, double> percents) {
  final cx = size.x / 2, cy = size.y / 2;
  final radius = math.min(size.x, size.y) * 0.34;

  PdfPoint at(int i, double rad) =>
      PdfPoint(cx + math.cos(hexAngle(i)) * rad, cy + math.sin(hexAngle(i)) * rad);

  void polygon(List<PdfPoint> pts) {
    canvas.moveTo(pts.first.x, pts.first.y);
    for (final p in pts.skip(1)) {
      canvas.lineTo(p.x, p.y);
    }
    canvas.closePath();
  }

  for (var step = 1; step <= 4; step++) {
    polygon([for (var i = 0; i < 6; i++) at(i, radius * step / 4)]);
    canvas
      ..setStrokeColor(BilanPalette.creamLine)
      ..setLineWidth(0.5)
      ..strokePath();
  }
  for (var i = 0; i < 6; i++) {
    canvas
      ..moveTo(cx, cy)
      ..lineTo(at(i, radius).x, at(i, radius).y)
      ..setStrokeColor(BilanPalette.creamLine)
      ..setLineWidth(0.5)
      ..strokePath();
  }
  final pts = [
    for (var i = 0; i < 6; i++)
      at(i, radius * ((percents[RiasecProfile.axes[i]] ?? 0).clamp(0, 100) / 100)),
  ];
  polygon(pts);
  canvas
    ..setFillColor(BilanPalette.radarFill)
    ..fillPath();
  polygon(pts);
  canvas
    ..setStrokeColor(BilanPalette.gold)
    ..setLineWidth(1.4)
    ..strokePath();
}
