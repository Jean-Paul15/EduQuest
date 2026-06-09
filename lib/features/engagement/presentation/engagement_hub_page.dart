import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/data/live_classes_repository.dart';
import 'package:eduquest/features/engagement/presentation/hub_data_loader.dart';
import 'package:eduquest/features/engagement/presentation/hub_tab_model.dart';
import 'package:eduquest/features/engagement/presentation/hub_tab_title.dart';
import 'package:eduquest/features/leaderboard/data/leaderboard_repository.dart';
import 'package:eduquest/features/notifications/data/user_notifications_repository.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
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
  List<HubTab> _tabs = const [];
  List<Widget> _pages = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    final flags = await safeHubFlags(_repo);
    final counts = await loadHubCounts(
      _lives,
      _engagement,
      _leaderboard,
      _notifications,
    );
    final tabs = buildHubTabs(flags, counts);
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_tabs.isEmpty) {
      return Scaffold(
        appBar: const RuachAppBar(title: 'Hub'),
        body: const Center(
          child: Text(
            'Hub temporairement indisponible.',
            style: TextStyle(color: RuachColors.cream500),
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
            dividerColor: RuachColors.cream200,
            tabs: [for (final t in _tabs) Tab(child: HubTabTitle(tab: t))],
          ),
        ),
        body: TabBarView(children: _pages),
      ),
    );
  }
}
