import 'dart:math' as math;

import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

/// Contraintes et préparation académique déclarées par l'élève (blocs « Ta
/// réalité » et « Ton niveau cette année »). Ce sont des paramètres de
/// **faisabilité**, jamais des traits psychologiques ni un motif d'élimination
/// silencieuse (voir KNOWLEDGE_BASE, B5).
class OrientationConstraints {
  const OrientationConstraints({
    this.budget = 3,
    this.mobility = 3,
    this.commitment = 3,
    this.familySupport = 3,
    this.selfEfficacySciences = 3,
    this.readinessMath = 3,
    this.readinessPhysiqueChimie = 3,
    this.readinessSvt = 3,
    this.readinessFrancais = 3,
    this.readinessLangues = 3,
    this.aspirationJob = '',
    this.aspirationSuccess = '',
  });

  /// Échelles 1-5 (3 = valeur neutre par défaut).
  /// `commitment` fusionne l'ancien couple durée + sélectivité (mig. 196).
  final int budget,
      mobility,
      commitment,
      familySupport,
      selfEfficacySciences,
      readinessMath,
      readinessPhysiqueChimie,
      readinessSvt,
      readinessFrancais,
      readinessLangues;
  final String aspirationJob, aspirationSuccess;

  static int _scale(Map<String, QuizAnswer> answers, String id) {
    final a = answers[id];
    return a is ScaleAnswer ? a.selected.clamp(1, 5) : 3;
  }

  static String _text(Map<String, QuizAnswer> answers, String id) {
    final a = answers[id];
    return a is ShortAnswerAnswer ? a.text.trim() : '';
  }

  factory OrientationConstraints.fromAnswers(Map<String, QuizAnswer> answers) =>
      OrientationConstraints(
        budget: _scale(answers, 'constraint_budget'),
        mobility: _scale(answers, 'constraint_mobility'),
        commitment: _scale(answers, 'constraint_commitment'),
        familySupport: _scale(answers, 'constraint_family_support'),
        selfEfficacySciences: _scale(answers, 'self_efficacy_sciences'),
        readinessMath: _scale(answers, 'readiness_math'),
        readinessPhysiqueChimie: _scale(answers, 'readiness_physique_chimie'),
        readinessSvt: _scale(answers, 'readiness_svt'),
        readinessFrancais: _scale(answers, 'readiness_francais'),
        readinessLangues: _scale(answers, 'readiness_langues'),
        aspirationJob: _text(answers, 'aspiration_job'),
        aspirationSuccess: _text(answers, 'aspiration_success'),
      );

  /// Sérialisation pour le RPC et l'edge. Les clés `duration` et
  /// `readiness_sciences` restent émises en rétrocompatibilité du RPC
  /// `orientation_match_fields` (mig. 193) : `readiness_sciences` prend la
  /// matière scientifique la plus faible (facteur limitant), `duration` reflète
  /// l'engagement. Les clés fines servent la narration IA.
  Map<String, dynamic> toJson() => {
    'budget': budget,
    'mobility': mobility,
    'duration': commitment,
    'commitment': commitment,
    'selectivity': commitment,
    'family_support': familySupport,
    'self_efficacy_sciences': selfEfficacySciences,
    'readiness_math': readinessMath,
    'readiness_sciences': math.min(readinessPhysiqueChimie, readinessSvt),
    'readiness_physique_chimie': readinessPhysiqueChimie,
    'readiness_svt': readinessSvt,
    'readiness_francais': readinessFrancais,
    'readiness_langues': readinessLangues,
    'aspiration_job': aspirationJob,
    'aspiration_success': aspirationSuccess,
  };
}
