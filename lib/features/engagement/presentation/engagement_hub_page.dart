import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/data/live_classes_repository.dart';
import 'package:eduquest/features/engagement/presentation/contests_page.dart';
import 'package:eduquest/features/engagement/presentation/events_page.dart';
import 'package:eduquest/features/engagement/presentation/live_classes_page.dart';
import 'package:eduquest/features/engagement/presentation/surveys_page.dart';
import 'package:eduquest/features/leaderboard/data/leaderboard_repository.dart';
import 'package:eduquest/features/leaderboard/presentation/leaderboard_page.dart';
import 'package:eduquest/features/marketplace/presentation/marketplace_page.dart';
import 'package:eduquest/features/notifications/data/user_notifications_repository.dart';
import 'package:eduquest/features/notifications/presentation/user_notifications_page.dart';
import 'package:eduquest/features/orientation/presentation/orientation_page.dart';
import 'package:eduquest/features/referral/presentation/referral_page.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class EngagementHubPage extends StatefulWidget {
  const EngagementHubPage({super.key});
  @override
  State<EngagementHubPage> createState() => _EngagementHubPageState();
}

class _EngagementHubPageState extends State<EngagementHubPage> {
  final _repo = AppConfigRepository();
  final _engagement = EngagementRepository();
  final _lives = LiveClassesRepository();
  final _leaderboard = LeaderboardRepository();
  final _notifications = UserNotificationsRepository();
  List<_HubTab> _tabs = const [];
  List<Widget> _pages = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    final flags = await _safeHubFlags();
    final c = await _loadCounts();
    final tabs = <_HubTab>[
      if (flags['live'] == true)
        _HubTab('Lives', c['live'] ?? 0, () => const LiveClassesPage()),
      if (flags['contests'] == true)
        _HubTab('Concours', c['contests'] ?? 0, () => const ContestsPage()),
      if (flags['events'] == true)
        _HubTab('Événements', c['events'] ?? 0, () => const EventsPage()),
      if (flags['surveys'] == true)
        _HubTab('Enquêtes', c['surveys'] ?? 0, () => const SurveysPage()),
      if (flags['notifications'] == true)
        _HubTab(
          'Notifications',
          c['notifications'] ?? 0,
          () => const UserNotificationsPage(),
        ),
      if (flags['referral'] == true)
        _HubTab('Parrainage', 0, () => const ReferralPage()),
      if (flags['market'] == true)
        _HubTab('Market', 0, () => const MarketplacePage(embedded: true)),
      if (flags['leaderboard'] == true)
        _HubTab(
          'Classement',
          c['leaderboard'] ?? 0,
          () => const LeaderboardPage(),
        ),
      if (flags['orientation'] == true)
        _HubTab('Orientation', 0, () => const OrientationPage()),
    ];
    if (!mounted) return;
    setState(() {
      _tabs = tabs;
      _pages = tabs.map((t) => t.build()).toList(growable: false);
      _loading = false;
    });
  }

  Future<Map<String, int>> _loadCounts() async {
    final out = <String, int>{'live': 0, 'contests': 0, 'events': 0, 'surveys': 0, 'leaderboard': 0, 'notifications': 0};
    try {
      out['live'] = (await _lives.list(forceRefresh: true)).length;
    } catch (_) {}
    try {
      out['contests'] = (await _engagement.listContests(forceRefresh: true)).length;
    } catch (_) {}
    try {
      out['events'] = (await _engagement.listEvents(forceRefresh: true)).length;
    } catch (_) {}
    try {
      out['surveys'] = (await _engagement.listSurveys(forceRefresh: true)).length;
    } catch (_) {}
    try {
      out['leaderboard'] = (await _leaderboard.weekly()).length;
    } catch (_) {}
    try {
      out['notifications'] = (await _notifications.list())
          .where((e) => e.readAt == null)
          .length;
    } catch (_) {}
    return out;
  }

  Future<Map<String, bool>> _safeHubFlags() async {
    try {
      return await _repo.loadHubModules();
    } catch (_) {
      return {
        'live': true,
        'contests': true,
        'events': true,
        'surveys': true,
        'notifications': true,
        'referral': true,
        'market': true,
        'leaderboard': true,
        'orientation': true,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_tabs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hub')),
        body: const Center(
          child: Text(
            'Hub temporairement indisponible.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return DefaultTabController(
      key: ValueKey(_tabs.length),
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hub'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerHeight: 0.5,
            dividerColor: AppColors.divider,
            tabs: [for (final t in _tabs) Tab(child: _TabTitle(tab: t))],
          ),
        ),
        body: TabBarView(children: _pages),
      ),
    );
  }
}

class _HubTab {
  const _HubTab(this.label, this.count, this.build);
  final String label;
  final int count;
  final Widget Function() build;
}

class _TabTitle extends StatelessWidget {
  const _TabTitle({required this.tab});
  final _HubTab tab;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    if (tab.count <= 0) {
      return Text(tab.label, style: TextStyle(color: textColor));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(tab.label, style: TextStyle(color: textColor)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${tab.count}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
