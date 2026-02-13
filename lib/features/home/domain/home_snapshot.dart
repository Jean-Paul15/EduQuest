import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/features/gamification/domain/daily_quest.dart';
import 'package:eduquest/features/gamification/domain/gamification_state.dart';

class HomeSnapshot {
  const HomeSnapshot({
    required this.displayName,
    required this.access,
    required this.gamification,
    required this.quests,
  });

  final String displayName;
  final AccessState access;
  final GamificationState gamification;
  final List<DailyQuest> quests;
}
