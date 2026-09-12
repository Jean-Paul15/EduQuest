import 'dart:math' as math;

import 'package:eduquest/features/orientation/data/pdf/bilan_pdf_hexagon.dart';
import 'package:eduquest/features/orientation/data/pdf/bilan_pdf_theme.dart';
import 'package:eduquest/features/orientation/domain/riasec_profile.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Bloc « profil d’intérêts » : hexagone RIASEC vectoriel + barres libellées.
pw.Widget bilanRadarBlock(Map<String, double> percents) => pw.Row(
  crossAxisAlignment: pw.CrossAxisAlignment.center,
  children: [
    _hexagon(percents),
    pw.SizedBox(width: 18),
    pw.Expanded(
      child: pw.Column(
        children: RiasecProfile.axes
            .map((a) => _bar(RiasecProfile.labels[a]!, percents[a] ?? 0))
            .toList(),
      ),
    ),
  ],
);

pw.Widget _hexagon(Map<String, double> percents) {
  const box = 148.0;
  const center = box / 2;
  const labelRadius = center * 0.92;
  return pw.SizedBox(
    width: box,
    height: box,
    child: pw.Stack(
      children: [
        pw.CustomPaint(
          size: const PdfPoint(box, box),
          painter: (canvas, size) => paintRiasecHexagon(canvas, size, percents),
        ),
        for (var i = 0; i < 6; i++)
          pw.Positioned(
            left: center + math.cos(hexAngle(i)) * labelRadius - 4,
            top: center + math.sin(hexAngle(i)) * labelRadius - 6,
            child: pw.Text(
              RiasecProfile.axes[i],
              style: pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold, color: BilanPalette.goldDeep),
            ),
          ),
      ],
    ),
  );
}

pw.Widget _bar(String label, double pct) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 5),
  child: pw.Row(children: [
    pw.SizedBox(width: 92, child: pw.Text(label, style: const pw.TextStyle(fontSize: 9))),
    pw.Expanded(
      child: pw.LinearProgressIndicator(
        value: pct.clamp(0, 100) / 100,
        minHeight: 7,
        backgroundColor: BilanPalette.cream,
        valueColor: BilanPalette.gold,
      ),
    ),
  ]),
);
