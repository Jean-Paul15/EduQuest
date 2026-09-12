import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/features/gamification/domain/daily_quest.dart';
import 'package:eduquest/features/gamification/domain/gamification_state.dart';
import 'package:eduquest/features/home/domain/home_snapshot.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';

class HomeSnapshotCache {
  final _local = LocalJsonCache();

  Future<HomeSnapshot?> read() async {
    final rows = await _local.readList('home:snapshot:v1');
    if (rows == null || rows.isEmpty) return null;
    final m = rows.first;
    return HomeSnapshot(
      displayName: '${m['displayName'] ?? 'Étudiant'}',
      access: AccessState(
        tier: '${m['tier'] ?? 'FREE_LIGHT'}',
        hasAccess: m['hasAccess'] as bool? ?? true,
        expiresAt: DateTime.tryParse('${m['expiresAt'] ?? ''}'),
        source: '${m['source'] ?? 'cache'}',
        freeOfferCode: '${m['freeOfferCode'] ?? 'FREE_LIGHT'}',
        scope: Map<String, dynamic>.from(
          (m['scope'] as Map?) ?? const <String, dynamic>{},
        ),
      ),
      gamification: GamificationState(
        xp: m['xp'] as int? ?? 0,
        level: m['level'] as int? ?? 1,
        streakDays: m['streakDays'] as int? ?? 0,
        bestStreak: m['bestStreak'] as int? ?? 0,
      ),
      quests: ((m['quests'] as List?) ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map(
            (q) => DailyQuest(
              id: '${q['id']}',
              code: '${q['code'] ?? q['id']}',
              label: '${q['label']}',
              xpReward: q['xpReward'] as int? ?? 0,
              completedToday: q['completedToday'] as bool? ?? false,
            ),
          )
          .toList(),
    );
  }

  Future<void> write(HomeSnapshot s) => _local.writeList('home:snapshot:v1', [
    {
      'displayName': s.displayName,
      'tier': s.access.tier,
      'hasAccess': s.access.hasAccess,
      'expiresAt': s.access.expiresAt?.toIso8601String(),
      'source': s.access.source,
      'freeOfferCode': s.access.freeOfferCode,
      'scope': s.access.scope,
      'xp': s.gamification.xp,
      'level': s.gamification.level,
      'streakDays': s.gamification.streakDays,
      'bestStreak': s.gamification.bestStreak,
      'quests': s.quests
          .map(
            (q) => {
              'id': q.id,
              'code': q.code,
              'label': q.label,
              'xpReward': q.xpReward,
              'completedToday': q.completedToday,
            },
          )
          .toList(),
    },
  ]);
}
