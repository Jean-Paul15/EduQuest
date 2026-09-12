import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruach_quiz_engine/presentation/tokens.dart';

/// Garde-fou anti-dérive : packages/ruach_quiz_engine/lib/presentation/tokens.dart
/// duplique volontairement les tokens numériques de RuachSpace/RuachRadius/RuachMotion
/// (le package ne peut pas dépendre de l'app hôte). Ce test échoue si les deux
/// échelles divergent après une modification de l'un des deux fichiers.
void main() {
  test('QuizRadius reste synchronisé avec RuachRadius', () {
    expect(QuizRadius.sm, RuachRadius.sm);
    expect(QuizRadius.md, RuachRadius.md);
    expect(QuizRadius.lg, RuachRadius.lg);
    expect(QuizRadius.xl, RuachRadius.xl);
    expect(QuizRadius.xxl, RuachRadius.xxl);
    expect(QuizRadius.full, RuachRadius.full);
  });

  test('QuizSpace reste synchronisé avec RuachSpace', () {
    expect(QuizSpace.s1, RuachSpace.s1);
    expect(QuizSpace.s2, RuachSpace.s2);
    expect(QuizSpace.s3, RuachSpace.s3);
    expect(QuizSpace.s4, RuachSpace.s4);
    expect(QuizSpace.s5, RuachSpace.s5);
    expect(QuizSpace.s6, RuachSpace.s6);
    expect(QuizSpace.s8, RuachSpace.s8);
  });

  test('QuizMotion reste synchronisé avec RuachMotion', () {
    expect(QuizMotion.tap, RuachMotion.tap);
    expect(QuizMotion.appear, RuachMotion.appear);
    expect(QuizMotion.statusAnim, RuachMotion.statusAnim);
  });
}
