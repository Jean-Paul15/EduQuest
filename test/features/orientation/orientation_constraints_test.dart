import 'package:eduquest/features/orientation/domain/orientation_constraints.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

void main() {
  test('fromAnswers lit les échelles et les textes libres', () {
    final c = OrientationConstraints.fromAnswers({
      'constraint_budget': const ScaleAnswer(questionId: 'constraint_budget', selected: 5),
      'constraint_mobility': const ScaleAnswer(questionId: 'constraint_mobility', selected: 1),
      'constraint_commitment': const ScaleAnswer(questionId: 'constraint_commitment', selected: 4),
      'self_efficacy_sciences': const ScaleAnswer(questionId: 'self_efficacy_sciences', selected: 2),
      'readiness_math': const ScaleAnswer(questionId: 'readiness_math', selected: 4),
      'readiness_physique_chimie':
          const ScaleAnswer(questionId: 'readiness_physique_chimie', selected: 5),
      'readiness_svt': const ScaleAnswer(questionId: 'readiness_svt', selected: 2),
      'readiness_langues': const ScaleAnswer(questionId: 'readiness_langues', selected: 3),
      'aspiration_job': const ShortAnswerAnswer(
        questionId: 'aspiration_job',
        text: '  ingénieur solaire  ',
      ),
    });
    expect(c.budget, 5);
    expect(c.mobility, 1);
    expect(c.commitment, 4);
    expect(c.selfEfficacySciences, 2);
    expect(c.readinessMath, 4);
    expect(c.readinessPhysiqueChimie, 5);
    expect(c.readinessSvt, 2);
    expect(c.aspirationJob, 'ingénieur solaire');
  });

  test('valeur neutre 3 quand la réponse est absente ou du mauvais type', () {
    final c = OrientationConstraints.fromAnswers({
      'constraint_budget': const ShortAnswerAnswer(
        questionId: 'constraint_budget',
        text: 'oops',
      ),
    });
    expect(c.budget, 3);
    expect(c.commitment, 3);
    expect(c.readinessFrancais, 3);
    expect(c.readinessLangues, 3);
    expect(c.aspirationJob, '');
  });

  test('toJson : clés rétrocompat du RPC + clés fines pour l’IA', () {
    final json = const OrientationConstraints(
      budget: 2,
      commitment: 4,
      readinessPhysiqueChimie: 5,
      readinessSvt: 1,
    ).toJson();
    expect(json['budget'], 2);
    // Rétrocompat RPC (mig. 193).
    expect(json['duration'], 4, reason: 'duration = commitment');
    expect(json['readiness_sciences'], 1, reason: 'matière scientifique la plus faible');
    // Clés fines.
    expect(json.keys, containsAll([
      'mobility', 'readiness_math', 'family_support', 'self_efficacy_sciences',
      'readiness_physique_chimie', 'readiness_svt', 'readiness_langues',
    ]));
  });
}
