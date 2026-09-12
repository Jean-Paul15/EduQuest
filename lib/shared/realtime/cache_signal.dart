/// Signal d'invalidation : « telle donnee a change en backend » (recu via
/// Broadcast Supabase ou via le RPC de rattrapage `content_changes_since`).
class CacheSignal {
  const CacheSignal({required this.hint, this.ref = const {}, this.op = 'UPDATE'});

  final String hint;
  final Map<String, dynamic> ref;
  final String op;

  static Map<String, dynamic> _refOf(Object? v) =>
      v is Map ? Map<String, dynamic>.from(v) : const {};

  factory CacheSignal.fromBroadcast(Map<String, dynamic> p) => CacheSignal(
    hint: '${p['hint'] ?? ''}',
    op: '${p['op'] ?? 'UPDATE'}',
    ref: _refOf(p['ref']),
  );

  factory CacheSignal.fromCatchupRow(Map<String, dynamic> r) => CacheSignal(
    hint: '${r['cache_hint'] ?? ''}',
    op: '${r['op'] ?? 'UPDATE'}',
    ref: _refOf(r['ref']),
  );

  /// Signal « tout le scope a peut-etre change » (absence longue, retour en
  /// ligne apres purge du journal) : tous les ecrans montes se rechargent.
  bool get isScopeReset => hint == '*';

  /// Namespace grossier pour reveiller les ecrans montes concernes.
  String get namespace => switch (hint) {
    'resources' || 'quiz_meta' || 'quizzes' => 'chapter',
    'chapters' || 'subjects' => 'learn',
    'exam_papers' => 'exam',
    'live_classes' => 'hub:lives',
    'contests' => 'hub:contests',
    'events' => 'hub:events',
    'surveys' => 'hub:surveys',
    'marketplace' => 'market',
    'app_config' => 'cfg',
    'leaderboard' => 'leaderboard',
    _ => hint,
  };
}

/// Scope resolu une fois au demarrage : ids (pour le topic realtime et la
/// plupart des cles) + codes (pour `videos:` / `feed:`).
class ScopeContext {
  const ScopeContext({
    this.seriesId,
    this.levelId,
    this.countryId,
    this.seriesCode,
    this.levelCode,
  });

  final String? seriesId, levelId, countryId, seriesCode, levelCode;

  String get sid => seriesId ?? '';
  String get lid => levelId ?? '';
  String get cid => countryId ?? '';
  String get sc => seriesCode ?? '';
  String get lc => levelCode ?? '';

  bool get isResolved =>
      (seriesId ?? '').isNotEmpty && (levelId ?? '').isNotEmpty;
}

/// Cibles de cache `LocalJsonCache` : `exact` = cles evincees + revalidees a
/// l'identique ; `prefixes` = namespaces entiers a vider.
typedef CacheTargets = ({List<String> exact, List<String> prefixes});
