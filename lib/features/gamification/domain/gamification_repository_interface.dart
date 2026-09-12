import 'package:eduquest/features/gamification/domain/daily_quest.dart';
import 'package:eduquest/features/gamification/domain/gamification_state.dart';
import 'package:eduquest/shared/core/result.dart';

abstract class GamificationRepositoryInterface {
  const GamificationRepositoryInterface();

  Future<Result<GamificationState>> loadState();
  Future<Result<List<DailyQuest>>> listDailyQuests();
  Future<Result<String>> claimDailyCheckin();
  Future<Result<String>> claimQuestByCode(String code);
}
