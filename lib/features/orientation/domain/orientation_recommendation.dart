import 'orientation_constraints.dart';
import 'recommended_field.dart';
import 'riasec_profile.dart';

/// Référence de source citée par l'IA d'analyse (issue du corpus RAG).
class SourceRef {
  const SourceRef({required this.institution, required this.title, this.url});
  final String institution, title;
  final String? url;

  factory SourceRef.fromJson(Map<String, dynamic> j) => SourceRef(
    institution: j['institution']?.toString() ?? '',
    title: j['title']?.toString() ?? '',
    url: j['url']?.toString(),
  );
}

/// Message d'incertitude affiché avant les recommandations (validité prédictive
/// réaliste, voir KNOWLEDGE_BASE, B5).
const kOrientationUncertaintyNote =
    'Ce test repère les filières où tu as le plus de chances d\'être motivé, de '
    'persévérer et d\'être satisfait. Le lien est réel mais modéré. Il ne prédit '
    'pas ta réussite aux examens : celle-ci dépend surtout de tes notes '
    'actuelles, de ta méthode de travail et de ta rigueur. À utiliser comme '
    'piste de réflexion, pas comme verdict.';

/// Résultat complet d'un bilan d'orientation : classement déterministe (RPC) +
/// narration IA optionnelle. `aiSummary == null` = mode dégradé (hors-ligne).
class OrientationRecommendation {
  const OrientationRecommendation({
    required this.profile,
    required this.constraints,
    required this.fields,
    this.aiSummary,
    this.constraintsAlignment,
    this.dimensionNotes = const {},
    this.strengths = const [],
    this.nextSteps = const [],
    this.sources = const [],
    this.relatedCourseIds = const [],
    this.uncertaintyNote = kOrientationUncertaintyNote,
    this.ragUsed = false,
    this.normsReady = false,
  });

  final RiasecProfile profile;
  final OrientationConstraints constraints;
  final List<RecommendedField> fields;
  final String? aiSummary, constraintsAlignment;

  /// Ce que chaque dimension RIASEC signifie **pour cet élève** (rédigé par
  /// l'IA dans le même appel que le reste, donc sans surcoût). Vide en mode
  /// dégradé : la section « dimensions » est simplement masquée.
  final Map<String, String> dimensionNotes;
  final List<String> strengths, nextSteps, relatedCourseIds;
  final List<SourceRef> sources;
  final String uncertaintyNote;
  final bool ragUsed, normsReady;

  Iterable<RecommendedField> tier(RecommendationTier t) =>
      fields.where((f) => f.tier == t);
}
