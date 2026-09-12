import 'package:flutter/material.dart';

/// Copie statique des tokens numériques de lib/shared/ui/design_tokens.dart —
/// ces valeurs (espacement, rayons, durées) ne dépendent jamais du thème
/// (contrairement aux couleurs de constants.dart), donc duplication directe
/// plutôt qu'une synchronisation à l'exécution. Non-régression garantie par
/// test/design/quiz_tokens_parity_test.dart côté app hôte : si ces valeurs
/// divergent de RuachRadius/RuachSpace/RuachMotion, ce test échoue.
class QuizRadius {
  QuizRadius._();
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const full = 999.0;
}

class QuizSpace {
  QuizSpace._();
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
}

class QuizMotion {
  QuizMotion._();
  static const tap = Duration(milliseconds: 100);
  static const appear = Duration(milliseconds: 200);
  static const statusAnim = Duration(milliseconds: 400);
}

class QuizCurves {
  QuizCurves._();
  static const tap = Curves.easeOut;
}
