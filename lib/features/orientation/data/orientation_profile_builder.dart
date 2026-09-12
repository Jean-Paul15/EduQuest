import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

import '../domain/orientation_constraints.dart';
import '../domain/recommended_field.dart';
import '../domain/riasec_profile.dart';
import 'riasec_scoring.dart';

/// Construit le profil de l'élève à partir d'un quiz terminé. Pur, sans réseau :
/// le classement des filières est fait par le RPC `orientation_match_fields`
/// (voir `OrientationRepository.matchFields`).
class OrientationProfileBuilder {
  const OrientationProfileBuilder._();

  static ({RiasecProfile profile, OrientationConstraints constraints}) build({
    required QuizResult result,
    required Map<String, QuizAnswer> answers,
    required QuizDefinition definition,
  }) => (
    profile: RiasecScoring.fromResult(
      result,
      itemsPerAxis: RiasecScoring.countAxisItems(definition),
    ),
    constraints: OrientationConstraints.fromAnswers(answers),
  );

  /// Repli hors-ligne minimal : familles de filières cohérentes avec les axes
  /// dominants, sans établissement ni score fin. Utilisé seulement si le RPC
  /// est injoignable — les libellés propres viennent normalement de
  /// `orientation_field_profiles` côté serveur.
  static List<RecommendedField> offlineFallback(RiasecProfile profile) {
    final codes = <String>{
      for (final axis in profile.top3) ...?_fieldsForAxis[axis],
    };
    return codes
        .take(6)
        .map(
          (code) => RecommendedField(
            fieldCode: code,
            label: _humanize(code),
            interestFit: 0,
            academicReadiness: 0,
            feasibility: 0,
            sPerson: 0,
            finalRank: 0,
            eligibility: EligibilityStatus.unknown,
            tier: RecommendationTier.ambitieux,
          ),
        )
        .toList(growable: false);
  }

  static String _humanize(String code) {
    final s = code.replaceAll('_', ' ');
    return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  }

  static const _fieldsForAxis = {
    'R': ['ingenierie', 'btp', 'energies_renouvelables', 'agro'],
    'I': ['sciences_fondamentales', 'informatique', 'sante', 'sciences_humaines'],
    'A': ['communication', 'lettres_langues'],
    'S': ['enseignement', 'sante', 'sciences_humaines'],
    'E': ['commerce_marketing', 'eco_gestion', 'droit', 'transport_logistique'],
    'C': ['comptabilite_finance', 'administration_secretariat', 'eco_gestion'],
  };
}
