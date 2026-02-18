import 'package:eduquest/features/gamification/data/gamification_repository.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';

class RevisionTracker {
  final _local = LocalJsonCache();
  final _gamification = GamificationRepository();

  DateTime start() => DateTime.now();

  Future<void> stop(DateTime startedAt) async {
    final seconds = DateTime.now().difference(startedAt).inSeconds;
    if (seconds <= 0) return;
    await _addSeconds(seconds);
  }

  Future<void> _addSeconds(int seconds) async {
    final day = DateTime.now().toUtc().toIso8601String().split('T').first;
    final key = 'gam:revision:$day';
    final row = (await _local.readList(key))?.first;
    final current = row?['seconds'] as int? ?? 0;
    final claimed = row?['claimed'] as bool? ?? false;
    final total = current + seconds;
    var nextClaimed = claimed;
    if (!claimed && total >= 900) {
      await _gamification.claimQuestByCode('review_15min');
      nextClaimed = true;
    }
    await _local.writeList(key, [
      {'seconds': total, 'claimed': nextClaimed},
    ]);
  }
}
