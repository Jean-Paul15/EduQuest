import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/engagement/presentation/contests_page.dart';
import 'package:eduquest/features/engagement/presentation/events_page.dart';
import 'package:eduquest/features/engagement/presentation/live_classes_page.dart';
import 'package:eduquest/features/engagement/presentation/surveys_page.dart';
import 'package:eduquest/features/leaderboard/presentation/leaderboard_page.dart';
import 'package:eduquest/features/marketplace/presentation/marketplace_page.dart';
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
  List<_HubTab> _tabs = const [];
  List<Widget> _pages = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    final flags = await _repo.loadHubModules();
    final tabs = <_HubTab>[
      if (flags['live'] == true)
        _HubTab('Lives', () => const LiveClassesPage()),
      if (flags['contests'] == true)
        _HubTab('Concours', () => const ContestsPage()),
      if (flags['events'] == true)
        _HubTab('Events', () => const EventsPage()),
      if (flags['surveys'] == true)
        _HubTab('Enquetes', () => const SurveysPage()),
      if (flags['referral'] == true)
        _HubTab('Parrainage', () => const ReferralPage()),
      if (flags['market'] == true)
        _HubTab('Market', () => const MarketplacePage(embedded: true)),
      if (flags['leaderboard'] == true)
        _HubTab('Classement', () => const LeaderboardPage()),
      if (flags['orientation'] == true)
        _HubTab('Orientation', () => const OrientationPage()),
    ];
    if (!mounted) return;
    setState(() {
      _tabs = tabs;
      _pages = tabs.map((t) => t.build()).toList(growable: false);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
            tabs: [for (final t in _tabs) Tab(text: t.label)],
          ),
        ),
        body: TabBarView(children: _pages),
      ),
    );
  }
}

class _HubTab {
  const _HubTab(this.label, this.build);
  final String label;
  final Widget Function() build;
}
