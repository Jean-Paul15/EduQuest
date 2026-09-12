import 'package:eduquest/features/engagement/domain/engagement_item.dart';
import 'package:eduquest/features/learning/domain/learning_subject.dart';

enum FeedKind { course, contest, event, recommendedChapter, unknown }

class FeedItem {
  const FeedItem({
    required this.id,
    required this.kind,
    required this.tag,
    required this.title,
    required this.subtitle,
    this.subjectId = '',
  });
  final String id;
  final FeedKind kind;
  final String tag;
  final String title;
  final String subtitle;

  /// Utilisé uniquement par [FeedKind.recommendedChapter] : le chapitre
  /// recommandé pointe vers la liste de chapitres de son sujet (navigation
  /// existante, pas de deep-link direct vers le chapitre — voir
  /// `FeedNavigator`).
  final String subjectId;

  factory FeedItem.fromMap(Map<String, dynamic> raw) {
    final kindName = raw['kind']?.toString() ?? '';
    final kind = FeedKind.values.firstWhere(
      (e) => e.name == kindName,
      orElse: () => FeedKind.unknown,
    );
    return FeedItem(
      id: raw['id']?.toString() ?? '',
      kind: kind,
      tag: raw['tag']?.toString() ?? '',
      title: raw['title']?.toString() ?? '',
      subtitle: raw['subtitle']?.toString() ?? '',
      subjectId: raw['subject_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'kind': kind.name,
    'tag': tag,
    'title': title,
    'subtitle': subtitle,
    'subject_id': subjectId,
  };
}

List<FeedItem> buildFeedItems({
  required Map<String, dynamic> feedCfg,
  required List<LearningSubject> subjects,
  required List<EngagementItem> contests,
  required List<EngagementItem> events,
  List<({String chapterId, String subjectId, String title})>
      recommendedChapters = const [],
}) {
  final showCourses = feedCfg['courses'] as bool? ?? true;
  final showContests = feedCfg['contests'] as bool? ?? true;
  final showEvents = feedCfg['events'] as bool? ?? true;
  final limitCourses = feedCfg['courses_limit'] as int? ?? 8;
  final limitContests = feedCfg['contests_limit'] as int? ?? 5;
  final limitEvents = feedCfg['events_limit'] as int? ?? 5;
  return <FeedItem>[
    // Pas de section vide si l'élève n'a aucun signal déclaratif : la liste
    // est simplement vide, jamais de contenu générique en substitution.
    ...recommendedChapters.map(
      (r) => FeedItem(
        id: r.chapterId,
        kind: FeedKind.recommendedChapter,
        tag: 'Recommandé pour toi',
        title: r.title,
        subtitle: 'D\'après tes matières préférées',
        subjectId: r.subjectId,
      ),
    ),
    if (showCourses)
      ...subjects.take(limitCourses).map(
        (s) => FeedItem(
          id: s.id,
          kind: FeedKind.course,
          tag: 'Cours',
          title: s.label,
          subtitle: 'Touchez pour ouvrir le parcours',
        ),
      ),
    if (showContests)
      ...contests.take(limitContests).map(
        (c) => FeedItem(
          id: c.id,
          kind: FeedKind.contest,
          tag: 'Concours',
          title: c.title,
          subtitle: c.subtitle,
        ),
      ),
    if (showEvents)
      ...events.take(limitEvents).map(
        (e) => FeedItem(
          id: e.id,
          kind: FeedKind.event,
          tag: 'Événement',
          title: e.title,
          subtitle: e.subtitle,
        ),
      ),
  ];
}
