import 'package:eduquest/features/engagement/presentation/contests_page.dart';
import 'package:eduquest/features/engagement/presentation/events_page.dart';
import 'package:eduquest/features/engagement/presentation/live_classes_page.dart';
import 'package:eduquest/features/engagement/presentation/surveys_page.dart';
import 'package:eduquest/features/leaderboard/presentation/leaderboard_page.dart';
import 'package:eduquest/features/marketplace/presentation/marketplace_page.dart';
import 'package:eduquest/features/notifications/presentation/user_notifications_page.dart';
import 'package:eduquest/features/orientation/presentation/orientation_page.dart';
import 'package:eduquest/features/referral/presentation/referral_page.dart';
import 'package:flutter/material.dart';

class HubTab {
  const HubTab(this.label, this.count, this.build);
  final String label;
  final int count;
  final Widget Function() build;
}

/// Ordre de priorité utilisé uniquement en cas d'égalité de `count` (y
/// compris l'égalité à 0) — le tri principal reste le volume de contenu
/// réel. Reflète la priorité produit d'accompagnement scolaire quotidien
/// (cours/concours/événements avant les modules secondaires).
const _importanceOrder = [
  'Concours',
  'Événements',
  'Lives',
  'Enquêtes',
  'Market',
  'Classement',
  'Notifications',
  'Orientation',
  'Parrainage',
];

List<HubTab> buildHubTabs(Map<String, bool> flags, Map<String, int> counts) {
  final c = counts;
  final tabs = [
    if (flags['live'] == true)
      HubTab(
        'Lives',
        c['live'] ?? 0,
        () => const LiveClassesPage(embedded: true),
      ),
    if (flags['contests'] == true)
      HubTab(
        'Concours',
        c['contests'] ?? 0,
        () => const ContestsPage(embedded: true),
      ),
    if (flags['events'] == true)
      HubTab(
        'Événements',
        c['events'] ?? 0,
        () => const EventsPage(embedded: true),
      ),
    if (flags['surveys'] == true)
      HubTab(
        'Enquêtes',
        c['surveys'] ?? 0,
        () => const SurveysPage(embedded: true),
      ),
    if (flags['notifications'] == true)
      HubTab(
        'Notifications',
        c['notifications'] ?? 0,
        () => const UserNotificationsPage(embedded: true),
      ),
    if (flags['referral'] == true)
      HubTab('Parrainage', 0, () => const ReferralPage(embedded: true)),
    if (flags['market'] == true)
      HubTab('Market', c['market'] ?? 0, () => const MarketplacePage(embedded: true)),
    if (flags['leaderboard'] == true)
      HubTab(
        'Classement',
        c['leaderboard'] ?? 0,
        () => const LeaderboardPage(embedded: true),
      ),
    if (flags['orientation'] == true)
      HubTab('Orientation', 0, () => const OrientationPage(embedded: true)),
  ];
  tabs.sort((a, b) {
    final rankCompare = _rank(a).compareTo(_rank(b));
    if (rankCompare != 0) return rankCompare;
    if (_rank(a) == 1) return b.count.compareTo(a.count);
    return _importanceOrder
        .indexOf(a.label)
        .compareTo(_importanceOrder.indexOf(b.label));
  });
  return tabs;
}

/// Rang de tri, évalué avant le volume de contenu :
/// - 0 : Notifications non lues (`count > 0`), toujours en tête.
/// - 1 : autres onglets à contenu non nul (hors Market), triés par `count`
///   décroissant.
/// - 2 : Market, uniquement s'il a du contenu — toujours derrière les
///   autres onglets non nuls, peu importe son propre chiffre.
/// - 3 : onglets sans contenu (dont Market et Notifications à 0), triés
///   par [_importanceOrder].
int _rank(HubTab t) {
  if (t.label == 'Notifications' && t.count > 0) return 0;
  if (t.label == 'Market') return t.count > 0 ? 2 : 3;
  return t.count > 0 ? 1 : 3;
}
