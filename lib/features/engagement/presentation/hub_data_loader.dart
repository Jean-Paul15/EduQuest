import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/data/live_classes_repository.dart';
import 'package:eduquest/features/leaderboard/data/leaderboard_repository.dart';
import 'package:eduquest/features/marketplace/data/marketplace_repository.dart';
import 'package:eduquest/features/notifications/data/user_notifications_repository.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';

const _hubSnapshotKey = 'hub:snapshot:v1';
final _hubLocal = LocalJsonCache();

Future<Map<String, bool>> safeHubFlags(
  AppConfigRepository repo, {
  bool forceRefresh = false,
}) async {
  try {
    return await repo.loadHubModules(forceRefresh: forceRefresh);
  } catch (_) {
    return {
      'live': true,
      'contests': true,
      'events': true,
      'surveys': true,
      'notifications': true,
      'referral': true,
      'market': true,
      'leaderboard': true,
      'orientation': true,
    };
  }
}

Future<Map<String, dynamic>?> readHubSnapshot() async {
  final rows = await _hubLocal.readList(_hubSnapshotKey);
  if (rows == null || rows.isEmpty) return null;
  return Map<String, dynamic>.from(rows.first);
}

Future<void> writeHubSnapshot({
  required Map<String, bool> flags,
  required Map<String, int> counts,
}) async {
  await _hubLocal.writeList(_hubSnapshotKey, [
    {
      'flags': flags,
      'counts': counts,
    },
  ]);
}

Future<Map<String, int>> loadHubCounts(
  LiveClassesRepository lives,
  EngagementRepository engagement,
  LeaderboardRepository leaderboard,
  UserNotificationsRepository notifications,
  MarketplaceRepository marketplace,
) async {
  // Chaque repository gère déjà son propre TTL (isFresh) -- plus de
  // forceRefresh systématique ici, qui court-circuitait le cache à chaque
  // ouverture du hub même avec une connexion disponible.
  final values = await Future.wait<int>([
    _safeCount(() => lives.list()),
    _safeCount(() => engagement.listContests()),
    _safeCount(() => engagement.listEvents()),
    _safeCount(() => engagement.listSurveys()),
    _safeCount(() => leaderboard.weekly()),
    _safeInt(() => notifications.unreadCount()),
    _safeCount(() => marketplace.search()),
  ]);
  final out = {
    'live': values[0],
    'contests': values[1],
    'events': values[2],
    'surveys': values[3],
    'leaderboard': values[4],
    'notifications': values[5],
    'market': values[6],
  };
  return out;
}

Future<int> _safeCount(Future<List<dynamic>> Function() loader) async {
  try {
    return (await loader()).length;
  } catch (_) {
    return 0;
  }
}

Future<int> _safeInt(Future<int> Function() loader) async {
  try {
    return await loader();
  } catch (_) {
    return 0;
  }
}
