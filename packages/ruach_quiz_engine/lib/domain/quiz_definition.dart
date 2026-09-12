import 'quiz_group.dart';
import 'quiz_question.dart';
import 'quiz_session_config.dart';
import 'quiz_content_block.dart';
import 'content_badge_computer.dart';

/// Définition complète d'un quiz : métadonnées + questions + configuration.
class QuizDefinition {
  const QuizDefinition({
    required this.id,
    required this.title,
    required this.questions,
    this.groups = const [],
    this.config = const QuizSessionConfig(),
    this.questionsPool = const [],
  });

  final String id;
  final String title;
  final List<QuizQuestion> questions;
  final List<QuestionGroup> groups;
  final QuizSessionConfig config;

  /// Pool de questions pour le mode `adaptive` (§12.2 du .md) — distinct de
  /// [questions], qui reste la liste fixe jouée en mode `standard`.
  final List<QuizQuestion> questionsPool;

  bool get isAdaptivePool =>
      config.mode == QuizMode.adaptive && questionsPool.isNotEmpty;

  /// Liste de questions effective de ce quiz : le pool en mode `adaptive`,
  /// la liste fixe sinon — point d'accès unique évitant de reproduire le
  /// ternaire `isAdaptivePool ? questionsPool : questions` à chaque usage.
  List<QuizQuestion> get effectiveQuestions =>
      isAdaptivePool ? questionsPool : questions;

  /// En mode adaptatif, le nombre réel de questions dépend du tirage
  /// (`config.questionsPerSession`, borné à la taille du pool) — pas de la
  /// liste [questions], vide pour ce type de quiz.
  int get totalQuestions => isAdaptivePool
      ? (config.questionsPerSession ?? questionsPool.length)
            .clamp(0, questionsPool.length)
      : questions.length;
  int get totalPoints =>
      effectiveQuestions.fold(0, (s, q) => s + q.points);
  bool get isEmpty => effectiveQuestions.isEmpty;

  /// Badges de contenu calculés automatiquement (∑ Formules, Images, Code...).
  List<ContentTypeBadge> get contentBadges => ContentBadgeComputer.compute(this);

  QuestionGroup? groupFor(String questionId) {
    final q = questions.where((x) => x.id == questionId).firstOrNull;
    if (q?.groupId == null) return null;
    return groups.where((g) => g.id == q!.groupId).firstOrNull;
  }
}
