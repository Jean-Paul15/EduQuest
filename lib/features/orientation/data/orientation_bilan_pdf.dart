import 'dart:typed_data';

import 'package:eduquest/features/orientation/data/pdf/bilan_pdf_fields.dart';
import 'package:eduquest/features/orientation/data/pdf/bilan_pdf_radar.dart';
import 'package:eduquest/features/orientation/data/pdf/bilan_pdf_theme.dart';
import 'package:eduquest/features/orientation/domain/orientation_recommendation.dart';
import 'package:eduquest/features/orientation/domain/riasec_profile.dart';
import 'package:pdf/widgets.dart' as pw;

/// Construit le bilan d'orientation en PDF **uniquement depuis les données
/// structurées renvoyées par l'edge function** : aucun texte de contenu figé
/// côté application, aucun appel réseau ni IA ici. Mise en page serif RuachEdu.
Future<Uint8List> buildOrientationBilanPdf(OrientationRecommendation reco) async {
  final doc = pw.Document();
  final p = reco.profile;
  final theme = await buildBilanTheme();

  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        margin: const pw.EdgeInsets.fromLTRB(38, 34, 38, 30),
        theme: theme,
      ),
      footer: bilanFooter,
      build: (context) => [
        bilanCover(p.hollandCode, _profileLine(p)),
        pw.SizedBox(height: 16),
        if ((reco.aiSummary ?? '').isNotEmpty) ...[
          pw.Text(reco.aiSummary!, style: const pw.TextStyle(fontSize: 11, lineSpacing: 3.5)),
          pw.SizedBox(height: 16),
        ],
        bilanSectionTitle('Ton profil d’intérêts'),
        bilanRadarBlock(p.percents),
        if (reco.dimensionNotes.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          bilanSectionTitle('Ce que révèlent tes dimensions'),
          ...p.top3.where(reco.dimensionNotes.containsKey).map(
                (a) => pw.Bullet(
                  text: '${RiasecProfile.labels[a]} : ${reco.dimensionNotes[a]}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
        ],
        pw.SizedBox(height: 14),
        ...bilanFieldSections(reco),
        if ((reco.constraintsAlignment ?? '').isNotEmpty) ...[
          bilanSectionTitle('Cohérence avec ta réalité'),
          pw.Text(reco.constraintsAlignment!, style: const pw.TextStyle(fontSize: 10.5)),
          pw.SizedBox(height: 14),
        ],
        if (reco.strengths.isNotEmpty) ...[
          bilanSectionTitle('Tes points forts'),
          ...reco.strengths.map((s) => pw.Bullet(text: s, style: const pw.TextStyle(fontSize: 10))),
          pw.SizedBox(height: 14),
        ],
        if (reco.nextSteps.isNotEmpty) ...[
          bilanSectionTitle('Tes prochaines étapes'),
          ...reco.nextSteps.map((s) => pw.Bullet(text: s, style: const pw.TextStyle(fontSize: 10))),
          pw.SizedBox(height: 14),
        ],
        if (reco.sources.isNotEmpty) ...[
          bilanSectionTitle('Sources'),
          ...reco.sources.map(
            (s) => pw.Bullet(
              text: [s.institution, s.title].where((x) => x.isNotEmpty).join(' — '),
              style: pw.TextStyle(fontSize: 8.5, color: BilanPalette.muted),
            ),
          ),
          pw.SizedBox(height: 14),
        ],
        pw.Divider(color: BilanPalette.creamLine),
        pw.Text(reco.uncertaintyNote,
            style: pw.TextStyle(fontSize: 9, color: BilanPalette.muted, lineSpacing: 2)),
      ],
    ),
  );
  return doc.save();
}

String? _profileLine(RiasecProfile p) {
  final top = p.top3.map((a) => RiasecProfile.labels[a]).whereType<String>().join(', ');
  return top.isEmpty ? null : 'Dominantes : $top';
}

/// Nom de fichier lisible et sans donnée personnelle pour le partage :
/// `Bilan-orientation-RuachEdu-IRC-2026-08-28.pdf`.
String orientationBilanFilename(OrientationRecommendation reco, [DateTime? now]) {
  final d = now ?? DateTime.now();
  final date = '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
  final code = reco.profile.hollandCode.isEmpty ? 'profil' : reco.profile.hollandCode;
  return 'Bilan-orientation-RuachEdu-$code-$date.pdf';
}
