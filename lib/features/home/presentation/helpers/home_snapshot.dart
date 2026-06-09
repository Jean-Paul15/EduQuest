import 'package:eduquest/features/home/domain/home_snapshot.dart';

(String, String, String?) widgetFocus(HomeSnapshot s) {
  final pending = s.quests.where((q) => !q.completedToday).toList();
  if (pending.isNotEmpty) {
    final q = pending.first;
    return (
      'Defi du jour',
      '${q.label} • +${q.xpReward} XP',
      'Touchez pour ouvrir RuachEdu',
    );
  }
  final exp = s.access.expiresAt;
  final d = exp?.difference(DateTime.now()).inDays;
  if (d != null && d <= 7) {
    return (
      'Ticket',
      '${s.access.tier} • Expire dans ${d < 0 ? 0 : d}j',
      'Touchez pour ouvrir RuachEdu',
    );
  }
  if (s.gamification.streakDays > 0) {
    return (
      'Serie active',
      '${s.gamification.streakDays} jours',
      'Touchez pour continuer',
    );
  }
  return (
    'Niveau',
    '${s.gamification.level} • ${s.gamification.xp} XP',
    'Touchez pour ouvrir RuachEdu',
  );
}
