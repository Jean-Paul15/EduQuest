/// Statut d'éligibilité d'une famille de filières pour la série de BAC de l'élève.
/// `unknown` n'est JAMAIS traité comme `ineligible` (KNOWLEDGE_BASE, B5).
enum EligibilityStatus {
  eligible,
  eligibleWithBridge,
  unknown,
  ineligible;

  static EligibilityStatus fromCode(String? code) => switch (code) {
    'ELIGIBLE' => EligibilityStatus.eligible,
    'ELIGIBLE_WITH_BRIDGE' => EligibilityStatus.eligibleWithBridge,
    'INELIGIBLE' => EligibilityStatus.ineligible,
    _ => EligibilityStatus.unknown,
  };
}

/// Regroupement de restitution : choix de sécurité / ambitieux (passerelle) /
/// alternative d'alternance.
enum RecommendationTier {
  securite,
  ambitieux,
  alternative;

  static RecommendationTier fromCode(String? code) => switch (code) {
    'securite' => RecommendationTier.securite,
    'alternative' => RecommendationTier.alternative,
    _ => RecommendationTier.ambitieux,
  };
}

/// Une famille de filières classée par le RPC `orientation_match_fields`.
/// Les 3 scores restent **distincts** dans l'UI : compatibilité, faisabilité,
/// confiance des données.
class RecommendedField {
  const RecommendedField({
    required this.fieldCode,
    required this.label,
    required this.interestFit,
    required this.academicReadiness,
    required this.feasibility,
    required this.sPerson,
    required this.finalRank,
    required this.eligibility,
    required this.tier,
    this.bridge,
    this.programs = const [],
    this.justification,
    this.dataConfidence,
  });

  final String fieldCode, label;
  final double interestFit, academicReadiness, feasibility, sPerson, finalRank;
  final EligibilityStatus eligibility;
  final RecommendationTier tier;
  final String? bridge, justification;
  final double? dataConfidence;
  final List<Map<String, dynamic>> programs;

  static double _num(Object? v) =>
      v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

  factory RecommendedField.fromRpcRow(Map<String, dynamic> row) =>
      RecommendedField(
        fieldCode: row['field_code']?.toString() ?? '',
        label: row['label']?.toString() ?? '',
        interestFit: _num(row['interest_fit']),
        academicReadiness: _num(row['academic_readiness']),
        feasibility: _num(row['feasibility']),
        sPerson: _num(row['s_person']),
        finalRank: _num(row['final_rank']),
        eligibility: EligibilityStatus.fromCode(row['eligibility']?.toString()),
        tier: RecommendationTier.fromCode(row['tier']?.toString()),
        bridge: (row['bridge'] as String?)?.trim().isEmpty ?? true
            ? null
            : row['bridge'].toString().trim(),
        programs: ((row['programs'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(growable: false),
      );

  RecommendedField mergeAi({String? justification, double? dataConfidence}) =>
      RecommendedField(
        fieldCode: fieldCode,
        label: label,
        interestFit: interestFit,
        academicReadiness: academicReadiness,
        feasibility: feasibility,
        sPerson: sPerson,
        finalRank: finalRank,
        eligibility: eligibility,
        tier: tier,
        bridge: bridge,
        programs: programs,
        justification: justification ?? this.justification,
        dataConfidence: dataConfidence ?? this.dataConfidence,
      );
}
