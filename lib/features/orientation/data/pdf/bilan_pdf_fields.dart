import 'package:eduquest/features/orientation/data/pdf/bilan_pdf_theme.dart';
import 'package:eduquest/features/orientation/domain/orientation_recommendation.dart';
import 'package:eduquest/features/orientation/domain/recommended_field.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const _tierTitles = {
  RecommendationTier.securite: 'Des choix sûrs',
  RecommendationTier.ambitieux: 'Des choix ambitieux',
  RecommendationTier.alternative: 'Des alternatives courtes',
};
const _eligibilityLabels = {
  EligibilityStatus.eligible: 'Accessible avec ta série',
  EligibilityStatus.eligibleWithBridge: 'Accessible via une passerelle',
  EligibilityStatus.ineligible: 'Non accessible avec ta série',
  EligibilityStatus.unknown: 'Conditions d’accès à vérifier',
};

/// Toutes les sections de familles (une par tier non vide).
List<pw.Widget> bilanFieldSections(OrientationRecommendation reco) => [
  for (final tier in RecommendationTier.values)
    if (reco.tier(tier).isNotEmpty) ...[
      bilanSectionTitle(_tierTitles[tier]!),
      ...reco.tier(tier).map(_fieldBlock),
      pw.SizedBox(height: 6),
    ],
];

pw.Widget _fieldBlock(RecommendedField f) => pw.Container(
  margin: const pw.EdgeInsets.only(bottom: 7),
  padding: const pw.EdgeInsets.all(10),
  decoration: pw.BoxDecoration(
    color: PdfColors.white,
    border: pw.Border.all(color: PdfColor.fromInt(0xFFE0C79E)),
    borderRadius: pw.BorderRadius.circular(4),
  ),
  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Text(f.label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: BilanPalette.ink)),
        ),
        _eligibilityPill(f.eligibility),
      ],
    ),
    if ((f.justification ?? '').isNotEmpty) ...[
      pw.SizedBox(height: 4),
      pw.Text(f.justification!, style: const pw.TextStyle(fontSize: 9.5)),
    ],
    if ((f.bridge ?? '').isNotEmpty) ...[
      pw.SizedBox(height: 3),
      pw.Text('Passerelle : ${f.bridge}',
          style: pw.TextStyle(fontSize: 9, color: BilanPalette.muted)),
    ],
    pw.SizedBox(height: 6),
    pw.Row(children: [
      _gauge('Compatibilité', f.interestFit),
      pw.SizedBox(width: 12),
      _gauge('Faisabilité', f.feasibility),
      if (f.dataConfidence != null) ...[
        pw.SizedBox(width: 12),
        _gauge('Fiabilité des infos', f.dataConfidence!),
      ],
    ]),
  ]),
);

pw.Widget _eligibilityPill(EligibilityStatus status) {
  final (fg, bg) = switch (status) {
    EligibilityStatus.eligible => (PdfColor.fromInt(0xFF3F7A4E), PdfColor.fromInt(0xFFE6F0E7)),
    EligibilityStatus.eligibleWithBridge => (BilanPalette.goldDeep, PdfColor.fromInt(0xFFF4E7CE)),
    EligibilityStatus.ineligible => (PdfColor.fromInt(0xFF9A4B3C), PdfColor.fromInt(0xFFF2E2DE)),
    EligibilityStatus.unknown => (BilanPalette.muted, BilanPalette.cream),
  };
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: pw.BoxDecoration(color: bg, borderRadius: pw.BorderRadius.circular(8)),
    child: pw.Text(_eligibilityLabels[status]!,
        style: pw.TextStyle(fontSize: 7.5, color: fg, fontWeight: pw.FontWeight.bold)),
  );
}

pw.Widget _gauge(String label, double value) => pw.Expanded(
  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Text(label, style: pw.TextStyle(fontSize: 7.5, color: BilanPalette.muted)),
    pw.SizedBox(height: 2),
    pw.LinearProgressIndicator(
      value: value.clamp(0, 1),
      minHeight: 4,
      backgroundColor: BilanPalette.cream,
      valueColor: BilanPalette.gold,
    ),
  ]),
);
