import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

import '../domain/riasec_profile.dart';

/// Transforme un `QuizResult` (sommes brutes par axe) en `RiasecProfile`
/// normalisé **intra-individuellement** — aucun étalonnage contre une population
/// tant que les normes locales n'existent pas (KNOWLEDGE_BASE, B6).
class RiasecScoring {
  const RiasecScoring._();

  /// [itemsPerAxis] : nombre d'items scorant chaque axe (10 pour le
  /// questionnaire v2). Chaque item vaut 0-4, donc le maximum d'un axe est
  /// `itemsPerAxis * 4`.
  static RiasecProfile fromResult(
    QuizResult result, {
    Map<String, int> itemsPerAxis = const {},
    int defaultItemsPerAxis = 10,
  }) {
    double pct(String axis) {
      final raw = result.axisScores[axis] ?? 0;
      final count = itemsPerAxis[axis] ?? defaultItemsPerAxis;
      final max = count * 4;
      if (max <= 0) return 0;
      return (raw / max * 100).clamp(0, 100).toDouble();
    }

    return RiasecProfile(
      r: pct('R'),
      i: pct('I'),
      a: pct('A'),
      s: pct('S'),
      e: pct('E'),
      c: pct('C'),
    );
  }

  /// Compte les items scorant chaque axe RIASEC dans une définition de quiz —
  /// robuste si le questionnaire évolue (ex. items image sur certains axes).
  static Map<String, int> countAxisItems(QuizDefinition definition) {
    final counts = <String, int>{};
    for (final q in definition.questions) {
      final axes = q.answerKey['axis_scores'];
      if (axes is! Map) continue;
      for (final key in axes.keys) {
        if (RiasecProfile.axes.contains(key)) {
          counts[key as String] = (counts[key] ?? 0) + 1;
        }
      }
    }
    return counts;
  }
}
