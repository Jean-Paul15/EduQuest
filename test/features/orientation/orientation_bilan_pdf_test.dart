import 'package:eduquest/features/orientation/data/orientation_bilan_pdf.dart';
import 'package:eduquest/features/orientation/domain/orientation_constraints.dart';
import 'package:eduquest/features/orientation/domain/orientation_recommendation.dart';
import 'package:eduquest/features/orientation/domain/recommended_field.dart';
import 'package:eduquest/features/orientation/domain/riasec_profile.dart';
import 'package:flutter_test/flutter_test.dart';

OrientationRecommendation _sample({bool minimal = false}) {
  const profile = RiasecProfile(r: 72, i: 88, a: 30, s: 45, e: 20, c: 61);
  final fields = [
    const RecommendedField(
      fieldCode: 'informatique',
      label: 'Informatique, numérique',
      interestFit: 0.91,
      academicReadiness: 0.8,
      feasibility: 0.7,
      sPerson: 0.86,
      finalRank: 0.83,
      eligibility: EligibilityStatus.eligible,
      tier: RecommendationTier.securite,
      justification: 'Ton goût pour comprendre et construire colle à ce domaine.',
      dataConfidence: 0.6,
    ),
    const RecommendedField(
      fieldCode: 'sante',
      label: 'Santé',
      interestFit: 0.62,
      academicReadiness: 0.4,
      feasibility: 0.5,
      sPerson: 0.55,
      finalRank: 0.5,
      eligibility: EligibilityStatus.eligibleWithBridge,
      tier: RecommendationTier.ambitieux,
      bridge: 'Remise à niveau en sciences',
      justification: 'Intérêt réel, prérequis à consolider.',
    ),
  ];
  return OrientationRecommendation(
    profile: profile,
    constraints: const OrientationConstraints(),
    fields: fields,
    aiSummary: minimal ? null : 'Salut Awa, voici ce que ton test dessine.',
    constraintsAlignment: minimal ? null : 'Ton budget serré oriente vers le public.',
    dimensionNotes: minimal ? const {} : const {'I': 'Tu aimes chercher le pourquoi.'},
    strengths: minimal ? const [] : const ['Rigueur', 'Curiosité technique'],
    nextSteps: minimal ? const [] : const ['Vérifier les dates de concours'],
    sources: minimal
        ? const []
        : const [SourceRef(institution: 'Université de Lomé', title: 'Offre de formation')],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('génère un PDF non vide depuis un bilan complet', () async {
    final bytes = await buildOrientationBilanPdf(_sample());
    expect(bytes.lengthInBytes, greaterThan(1000));
    expect(bytes.sublist(0, 4), [0x25, 0x50, 0x44, 0x46]); // %PDF
  });

  test('génère un PDF en mode dégradé (sans narration IA)', () async {
    final bytes = await buildOrientationBilanPdf(_sample(minimal: true));
    expect(bytes.lengthInBytes, greaterThan(1000));
  });

  test('nom de fichier lisible, daté, sans donnée personnelle', () {
    final name = orientationBilanFilename(_sample(), DateTime(2026, 8, 28));
    expect(name, 'Bilan-orientation-RuachEdu-IRC-2026-08-28.pdf');
  });
}
