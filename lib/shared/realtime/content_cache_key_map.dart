import 'package:eduquest/shared/realtime/cache_signal.dart';

/// Traduit un [CacheSignal] + le scope courant en cibles de cache exactes.
/// Miroir cote client de la logique de clefs des repos (`chapter:res:...`,
/// `learn:chapters:...`, `exam:papers:...`, `hub:*`, `cfg:*`, ...).
class ContentCacheKeys {
  const ContentCacheKeys._();

  static const _resTypes = ['pdf', 'exercise_set', 'summary', 'video', 'youtube'];
  static const _examCats = ['national', 'epreuve', 'mock'];

  /// Prefixes du contenu scope par niveau/serie (fallback absence longue +
  /// changement de classe).
  static const scopedPrefixes = [
    'chapter:', 'learn:', 'exam:', 'hub:', 'videos:', 'video:filters:',
    'feed:', 'market:', 'leaderboard:', 'cfg:',
  ];

  static CacheTargets targetsFor(CacheSignal s, ScopeContext c) {
    if (s.isScopeReset) return (exact: const [], prefixes: scopedPrefixes);
    final r = s.ref;
    final chapterId = '${r['chapter_id'] ?? ''}';
    final subjectId = '${r['subject_id'] ?? ''}';
    final quizId = '${r['quiz_id'] ?? ''}';
    final type = '${r['type'] ?? ''}';
    final feedKey = 'feed:${c.lc}:${c.sc}';

    switch (s.hint) {
      case 'resources':
        final types = type.isNotEmpty ? [type] : _resTypes;
        return (
          exact: [
            if (chapterId.isNotEmpty)
              for (final t in types) 'chapter:res:${c.sid}:$chapterId:$t',
            for (final t in types) 'learn:res:$t',
            if (type.isEmpty || type == 'video' || type == 'youtube')
              'videos:${c.lc}:${c.sc}',
            feedKey,
          ],
          prefixes: const [],
        );
      case 'quizzes':
        return (
          exact: [
            if (chapterId.isNotEmpty) 'chapter:qcm:${c.sid}:$chapterId',
            if (quizId.isNotEmpty) 'learn:qcm:v2:bundle:$quizId',
          ],
          prefixes: const [],
        );
      case 'quiz_meta':
        return (
          exact: quizId.isEmpty
              ? const []
              : [
                  'learn:qcm:v2:bundle:$quizId',
                  'learn:qcm:v2:q:$quizId',
                  'learn:qcm:v2:pool:$quizId',
                  'learn:qcm:v2:groups:$quizId',
                  'learn:qcm:v2:config:$quizId',
                ],
          prefixes: const [],
        );
      case 'chapters':
      case 'subjects':
        return (
          exact: [
            'learn:subjects:course:${c.lid}:${c.sid}',
            if (subjectId.isNotEmpty)
              'learn:chapters:${c.lid}:${c.sid}:$subjectId',
          ],
          prefixes:
              subjectId.isEmpty ? ['learn:chapters:${c.lid}:${c.sid}:'] : const [],
        );
      case 'exam_papers':
        return (
          exact: [
            for (final cat in _examCats) ...[
              'exam:subjects:$cat:${c.cid}:${c.lid}:${c.sid}',
              if (subjectId.isNotEmpty)
                'exam:papers:$cat:${c.cid}:${c.lid}:${c.sid}:$subjectId',
            ],
          ],
          prefixes: subjectId.isEmpty ? const ['exam:papers:'] : const [],
        );
      case 'live_classes':
        return (exact: ['hub:lives:${c.lid}:${c.sid}'], prefixes: const []);
      case 'contests':
        return (exact: ['hub:contests', feedKey], prefixes: const []);
      case 'events':
        return (exact: ['hub:events', feedKey], prefixes: const []);
      case 'surveys':
        return (exact: const ['hub:surveys'], prefixes: const []);
      case 'marketplace':
        return (exact: const [], prefixes: const ['market:']);
      case 'app_config':
        final key = '${r['key'] ?? ''}';
        return key.isEmpty
            ? (exact: const [], prefixes: const ['cfg:'])
            : (exact: ['cfg:$key'], prefixes: const []);
      case 'leaderboard':
        return (
          exact: const ['leaderboard:weekly', 'leaderboard:policy'],
          prefixes: const [],
        );
      default:
        return (exact: const [], prefixes: const []);
    }
  }
}
