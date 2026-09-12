import 'package:eduquest/features/class_selection/domain/level_option.dart';
import 'package:eduquest/features/class_selection/domain/series_option.dart';
import 'package:eduquest/features/learning/domain/learning_chapter.dart';
import 'package:eduquest/features/learning/domain/learning_subject.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

const testLevels = [
  LevelOption(id: 'term', code: 'TLE', label: 'Terminale'),
];
const testSeries = [
  SeriesOption(id: 'd', code: 'D', label: 'Série D'),
];
const testSubjects = [
  LearningSubject(id: 'math', code: 'MATH', label: 'Mathématiques'),
];
const testChapters = [
  LearningChapter(id: 'ch1', title: 'Fonctions', position: 1),
];

QuizDefinition buildQuizDefinition() => const QdlParser().parseFull({
  'quiz': {
    'id': 'quiz-1',
    'title': 'QCM de test',
    'questions': [
      {
        'id': 'q1',
        'type': 'single_choice',
        'prompt': 'Combien font 2 + 2 ?',
        'choices': ['3', '4', '5'],
        'answer_key': {'correct': '4'},
      },
    ],
  },
});

QuizDefinition buildOrientationDefinition() => const QdlParser().parseFull({
  'quiz': {
    'id': 'orientation',
    'title': 'Orientation scientifique',
    'config': {'mode': 'orientation', 'allow_skip': false},
    'groups': [
      {'id': 'bloc1', 'title': 'Bloc 1'},
    ],
    'questions': [
      {
        'id': 'o1',
        'type': 'scale',
        'group_id': 'bloc1',
        'prompt': 'J’aime analyser des problèmes complexes.',
        'answer_key': {'min': 1, 'max': 5, 'axis_scores': {'I': {'5': 5}}},
      },
    ],
  },
});
