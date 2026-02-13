class DailyQuest {
  const DailyQuest({
    required this.id,
    required this.label,
    required this.xpReward,
    required this.completedToday,
  });

  final String id;
  final String label;
  final int xpReward;
  final bool completedToday;
}

