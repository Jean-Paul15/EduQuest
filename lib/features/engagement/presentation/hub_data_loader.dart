import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/data/live_classes_repository.dart';
import 'package:eduquest/features/leaderboard/data/leaderboard_repository.dart';
import 'package:eduquest/features/notifications/data/user_notifications_repository.dart';

Future<Map<String, bool>> safeHubFlags(AppConfigRepository repo) async {
  try {
    return await repo.loadHubModules();
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

Future<Map<String, int>> loadHubCounts(
  LiveClassesRepository lives,
  EngagementRepository engagement,
  LeaderboardRepository leaderboard,
  UserNotificationsRepository notifications,
) async {
  final out = <String, int>{
    'live': 0,
    'contests': 0,
    'events': 0,
    'surveys': 0,
    'leaderboard': 0,
    'notifications': 0,
  };
  try {
    out['live'] = (await lives.list(forceRefresh: true)).length;
  } catch (_) {}
  try {
    out['contests'] =
        (await engagement.listContests(forceRefresh: true)).length;
  } catch (_) {}
  try {
    out['events'] = (await engagement.listEvents(forceRefresh: true)).length;
  } catch (_) {}
  try {
    out['surveys'] =
        (await engagement.listSurveys(forceRefresh: true)).length;
  } catch (_) {}
  try {
    out['leaderboard'] = (await leaderboard.weekly()).length;
  } catch (_) {}
  try {
    out['notifications'] =
        (await notifications.list()).where((e) => e.readAt == null).length;
  } catch (_) {}
  return out;
}
