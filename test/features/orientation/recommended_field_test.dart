import 'package:eduquest/features/orientation/domain/recommended_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromRpcRow mappe scores, enums et programmes', () {
    final f = RecommendedField.fromRpcRow({
      'field_code': 'informatique',
      'label': 'Informatique',
      'interest_fit': '0.912',
      'academic_readiness': 0.7,
      'feasibility': 0.8,
      's_person': 0.86,
      'final_rank': 0.85,
      'eligibility': 'ELIGIBLE_WITH_BRIDGE',
      'tier': 'ambitieux',
      'bridge': 'Renforcement maths',
      'programs': [
        {'program_id': 'p1', 'title': 'Licence Génie Logiciel'},
      ],
    });
    expect(f.interestFit, closeTo(0.912, 1e-9));
    expect(f.eligibility, EligibilityStatus.eligibleWithBridge);
    expect(f.tier, RecommendationTier.ambitieux);
    expect(f.bridge, 'Renforcement maths');
    expect(f.programs.single['title'], 'Licence Génie Logiciel');
  });

  test('valeurs inconnues -> defaults sûrs (unknown / ambitieux), bridge null', () {
    final f = RecommendedField.fromRpcRow({
      'field_code': 'droit',
      'label': 'Droit',
      'eligibility': null,
      'tier': null,
      'bridge': '',
      'programs': null,
    });
    expect(f.eligibility, EligibilityStatus.unknown);
    expect(f.tier, RecommendationTier.ambitieux);
    expect(f.bridge, isNull);
    expect(f.programs, isEmpty);
    expect(f.interestFit, 0);
  });

  test('mergeAi ajoute justification + confiance sans toucher au reste', () {
    final base = RecommendedField.fromRpcRow({
      'field_code': 'agro',
      'label': 'Agronomie',
      'final_rank': 0.7,
      'eligibility': 'ELIGIBLE',
      'tier': 'securite',
    });
    final merged = base.mergeAi(justification: 'Profil terrain', dataConfidence: 0.4);
    expect(merged.justification, 'Profil terrain');
    expect(merged.dataConfidence, 0.4);
    expect(merged.finalRank, 0.7);
    expect(merged.eligibility, EligibilityStatus.eligible);
  });
}
