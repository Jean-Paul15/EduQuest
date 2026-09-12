class DailyQuest {
  const DailyQuest({
    required this.id,
    required this.code,
    required this.label,
    required this.xpReward,
    required this.completedToday,
  });

  final String id;
  final String code;
  final String label;
  final int xpReward;
  final bool completedToday;
}
