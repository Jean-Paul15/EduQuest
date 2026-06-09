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

List<HubTab> buildHubTabs(Map<String, bool> flags, Map<String, int> counts) {
  final c = counts;
  return [
    if (flags['live'] == true)
      HubTab('Lives', c['live'] ?? 0, () => const LiveClassesPage()),
    if (flags['contests'] == true)
      HubTab('Concours', c['contests'] ?? 0, () => const ContestsPage()),
    if (flags['events'] == true)
      HubTab('Événements', c['events'] ?? 0, () => const EventsPage()),
    if (flags['surveys'] == true)
      HubTab('Enquêtes', c['surveys'] ?? 0, () => const SurveysPage()),
    if (flags['notifications'] == true)
      HubTab(
        'Notifications',
        c['notifications'] ?? 0,
        () => const UserNotificationsPage(),
      ),
    if (flags['referral'] == true)
      HubTab('Parrainage', 0, () => const ReferralPage()),
    if (flags['market'] == true)
      HubTab('Market', 0, () => const MarketplacePage(embedded: true)),
    if (flags['leaderboard'] == true)
      HubTab(
        'Classement',
        c['leaderboard'] ?? 0,
        () => const LeaderboardPage(),
      ),
    if (flags['orientation'] == true)
      HubTab('Orientation', 0, () => const OrientationPage()),
  ];
}
