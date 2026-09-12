import 'package:eduquest/features/home/domain/home_snapshot.dart';
import 'package:eduquest/features/home/domain/motivational_quote.dart';
import 'package:eduquest/features/widget/data/home_widget_service.dart';

/// Assemble tous les ingrédients du widget écran d'accueil. Le choix de LA
/// face à afficher (quête / progression / série / ticket ⇄ citation) est fait
/// côté natif selon l'heure et l'urgence — ici on ne fait que fournir la
/// matière fraîche.
WidgetPayload widgetPayload(HomeSnapshot s, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final xpPct = (s.gamification.levelProgress * 100).round().clamp(0, 100);

  final pending = s.quests.where((q) => !q.completedToday).toList();
  final hasQuest = pending.isNotEmpty;
  final quest = hasQuest ? pending.first : null;

  final exp = s.access.expiresAt;
  final rawDays = exp?.difference(n).inDays;
  final ticketDays = (rawDays != null && rawDays <= 7) ? (rawDays < 0 ? 0 : rawDays) : -1;

  return WidgetPayload(
    name: s.displayName,
    xpPct: xpPct,
    xpLabel: '$xpPct % vers Niv. ${s.gamification.level + 1}',
    level: s.gamification.level,
    streak: s.gamification.streakDays,
    questLabel: hasQuest ? 'Défi du jour' : '',
    questValue: hasQuest ? '${quest!.label} · +${quest.xpReward} XP' : '',
    ticketTier: ticketDays >= 0 ? s.access.tier : '',
    ticketDays: ticketDays,
    quote: kMotivationalQuote,
    quoteAuthor: kMotivationalQuoteAuthor,
  );
}
