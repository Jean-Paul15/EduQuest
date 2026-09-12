import 'package:eduquest/features/orientation/data/orientation_repository.dart';
import 'package:eduquest/features/orientation/domain/orientation_constraints.dart';
import 'package:eduquest/features/orientation/domain/orientation_recommendation.dart';
import 'package:eduquest/features/orientation/domain/recommended_field.dart';
import 'package:eduquest/features/orientation/domain/riasec_profile.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

class FakeOrientationRepository extends OrientationRepository {
  FakeOrientationRepository({
    required this.definition,
    this.draft,
    this.error,
    this.result,
  });

  final QuizDefinition definition;
  final QuizSessionSnapshot? draft;
  final OrientationUnavailable? error;
  final OrientationRecommendation? result;

  @override
  String? get activeVersion => 'test-v1';

  @override
  Future<QuizDefinition> activeQuestionnaire() async {
    if (error != null) throw error!;
    return definition;
  }

  @override
  Future<QuizSessionSnapshot?> loadDraft() async => draft;

  @override
  Future<List<RecommendedField>> matchFields({
    required RiasecProfile profile,
    required OrientationConstraints constraints,
    required String seriesCode,
    String? academicYear,
  }) async => const [
    RecommendedField(
      fieldCode: 'informatique',
      label: 'Informatique, numérique',
      interestFit: 0.92,
      academicReadiness: 0.8,
      feasibility: 0.7,
      sPerson: 0.87,
      finalRank: 0.84,
      eligibility: EligibilityStatus.eligible,
      tier: RecommendationTier.securite,
    ),
  ];

  @override
  Future<OrientationRecommendation> analyzeCompleted({
    required QuizSessionSnapshot snapshot,
    required RiasecProfile profile,
    required OrientationConstraints constraints,
    required List<RecommendedField> fields,
    required String seriesCode,
    required String questionnaireVersion,
    Map<String, dynamic>? learner,
    String? academicYear,
  }) async {
    if (error != null) throw error!;
    return result ??
        OrientationRecommendation(
          profile: profile,
          constraints: constraints,
          fields: fields,
          aiSummary: 'Bilan de test prêt.',
        );
  }
}
