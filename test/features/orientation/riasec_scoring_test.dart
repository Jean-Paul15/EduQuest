import 'package:eduquest/features/orientation/data/riasec_scoring.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

QuizResult _result(Map<String, double> axisScores) => QuizResult(
  mode: QuizMode.orientation,
  totalQuestions: 0,
  totalPoints: 0,
  correctCount: 0,
  wrongCount: 0,
  skippedCount: 0,
  earnedPoints: 0,
  totalTimeSeconds: 0,
  perQuestion: const [],
  passingScorePercent: 0,
  axisScores: axisScores,
);

void main() {
  test('normalisation intra-individuelle : raw / (items * 4) * 100', () {
    final profile = RiasecScoring.fromResult(
      _result({'R': 10, 'I': 40, 'A': 0, 'S': 20, 'E': 8, 'C': 32}),
      itemsPerAxis: const {'R': 10, 'I': 10, 'A': 10, 'S': 10, 'E': 10, 'C': 10},
    );
    expect(profile.i, 100); // 40 / 40 * 100
    expect(profile.r, 25); // 10 / 40 * 100
    expect(profile.a, 0);
    expect(profile.top3, ['I', 'C', 'S']);
    expect(profile.hollandCode, 'ICS');
  });

  test('un axe sans réponse reste à 0, jamais négatif', () {
    final profile = RiasecScoring.fromResult(
      _result({'I': 12}),
      itemsPerAxis: const {'I': 10},
    );
    expect(profile.r, 0);
    expect(profile.i, 30);
  });

  test('le score est borné à 100 même si le brut dépasse le max théorique', () {
    final profile = RiasecScoring.fromResult(
      _result({'R': 999}),
      itemsPerAxis: const {'R': 10},
    );
    expect(profile.r, 100);
  });

  test('countAxisItems compte les items scorant chaque axe RIASEC', () {
    final def = const QdlParser().parseFull({
      'quiz': {
        'id': 'q',
        'title': 't',
        'config': {'mode': 'orientation'},
        'groups': [
          {'id': 'g', 'title': 'g'},
        ],
        'questions': [
          {
            'id': 'r1',
            'type': 'scale',
            'group_id': 'g',
            'prompt': 'p',
            'answer_key': {
              'min': 1,
              'max': 5,
              'axis_scores': {
                'R': {'5': 4},
              },
            },
          },
          {
            'id': 'r2',
            'type': 'scale',
            'group_id': 'g',
            'prompt': 'p',
            'answer_key': {
              'min': 1,
              'max': 5,
              'axis_scores': {
                'R': {'5': 4},
              },
            },
          },
          {
            'id': 'x',
            'type': 'scale',
            'group_id': 'g',
            'prompt': 'p',
            'answer_key': {'min': 1, 'max': 5},
          },
        ],
      },
    });
    expect(RiasecScoring.countAxisItems(def), {'R': 2});
  });
}
