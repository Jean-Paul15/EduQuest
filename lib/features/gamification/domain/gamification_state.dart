class GamificationState {
  const GamificationState({
    required this.xp,
    required this.level,
    required this.streakDays,
    required this.bestStreak,
  });

  final int xp;
  final int level;
  final int streakDays;
  final int bestStreak;

  double get levelProgress => (xp % 120) / 120;
}

