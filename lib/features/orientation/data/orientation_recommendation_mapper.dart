import '../domain/orientation_constraints.dart';
import '../domain/orientation_recommendation.dart';
import '../domain/recommended_field.dart';
import '../domain/riasec_profile.dart';

/// Désérialisation des recommandations : ni le domaine ni l'UI ne connaissent la
/// forme JSON renvoyée par l'edge function `ai-orientation-analyze`.
class OrientationRecommendationMapper {
  const OrientationRecommendationMapper._();

  static List<String> _strings(Object? v) => (v as List? ?? const [])
      .map((e) => e.toString())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);

  /// Fusionne le classement déterministe `fields` avec la narration IA.
  static OrientationRecommendation fromEdgeJson(
    Map<String, dynamic> json, {
    required RiasecProfile profile,
    required OrientationConstraints constraints,
    required List<RecommendedField> fields,
  }) {
    final aiFields = <String, Map<String, dynamic>>{
      for (final f in (json['recommended_fields'] as List? ?? const []))
        if (f is Map && f['field_code'] != null)
          f['field_code'].toString(): Map<String, dynamic>.from(f),
    };
    return OrientationRecommendation(
      profile: profile,
      constraints: constraints,
      fields: [
        for (final f in fields)
          if (aiFields.containsKey(f.fieldCode))
            f.mergeAi(
              justification: aiFields[f.fieldCode]!['justification']?.toString(),
              dataConfidence:
                  (aiFields[f.fieldCode]!['data_confidence'] as num?)?.toDouble(),
            )
          else
            f,
      ],
      aiSummary: json['profile_summary']?.toString(),
      constraintsAlignment: json['constraints_alignment']?.toString(),
      dimensionNotes: {
        for (final e in (json['dimension_notes'] as Map? ?? const {}).entries)
          if ('${e.value}'.trim().isNotEmpty) '${e.key}': '${e.value}'.trim(),
      },
      strengths: _strings(json['strengths_highlighted']),
      nextSteps: _strings(json['next_steps']),
      relatedCourseIds: _strings(json['related_ruachedu_courses']),
      sources: ((json['sources'] as List? ?? const []))
          .whereType<Map>()
          .map((e) => SourceRef.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false),
      uncertaintyNote:
          json['uncertainty_note']?.toString() ?? kOrientationUncertaintyNote,
      ragUsed: json['rag_used'] == true,
      normsReady: json['norms_ready'] == true,
    );
  }

  /// Repli déterministe : aucun réseau, donc aucune narration IA. On n'expose
  /// que ce qui se dérive des données (profil + classement) ; les sections
  /// rédigées (synthèse, notes de dimension, étapes) restent vides et l'écran
  /// les masque.
  static OrientationRecommendation deterministic({
    required RiasecProfile profile,
    required OrientationConstraints constraints,
    required List<RecommendedField> fields,
  }) => OrientationRecommendation(
    profile: profile,
    constraints: constraints,
    fields: fields,
  );
}
