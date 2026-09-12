import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/data/live_classes_repository.dart';
import 'package:eduquest/features/engagement/presentation/hub_data_loader.dart';
import 'package:eduquest/features/engagement/presentation/hub_tab_model.dart';
import 'package:eduquest/features/engagement/presentation/hub_tab_title.dart';
import 'package:eduquest/features/leaderboard/data/leaderboard_repository.dart';
import 'package:eduquest/features/marketplace/data/marketplace_repository.dart';
import 'package:eduquest/features/notifications/data/user_notifications_repository.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_progress.dart';
import 'package:eduquest/shared/ui/widgets/ruach_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:eduquest/shared/realtime/realtime_refreshable.dart';

class EngagementHubPage extends StatefulWidget {
  const EngagementHubPage({super.key});
  @override
  State<EngagementHubPage> createState() => _EngagementHubPageState();
}

class _EngagementHubPageState extends State<EngagementHubPage>
    with RealtimeRefreshable<EngagementHubPage> {
  @override
  List<String> get realtimeNamespaces => const ['hub'];

  @override
  Future<void> reloadFromRealtime() => _loadModules();

  final _repo = AppConfigRepository();
  final _engagement = EngagementRepository();
  final _lives = LiveClassesRepository();
  final _leaderboard = LeaderboardRepository();
  final _notifications = UserNotificationsRepository();
  final _marketplace = MarketplaceRepository();
  List<HubTab> _tabs = const [];
  List<Widget> _pages = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _primeFromCache();
    _loadModules();
  }

  Future<void> _primeFromCache() async {
    final cached = await readHubSnapshot();
    if (!mounted || cached == null) return;
    final flags = Map<String, bool>.from((cached['flags'] as Map?) ?? {});
    final counts = Map<String, int>.from(
      ((cached['counts'] as Map?) ?? {}).map(
        (k, v) => MapEntry('$k', v is num ? v.toInt() : 0),
      ),
    );
    final tabs = buildHubTabs(flags, counts);
    if (tabs.isEmpty) return;
    setState(() {
      _tabs = tabs;
      _pages = tabs.map((t) => t.build()).toList(growable: false);
      _loading = false;
    });
  }

  Future<void> _loadModules() async {
    final hadTabs = _tabs.isNotEmpty;
    setState(() {
      _loading = !hadTabs;
      _error = null;
    });
    try {
      final results = await Future.wait<dynamic>([
        safeHubFlags(_repo, forceRefresh: true),
        loadHubCounts(_lives, _engagement, _leaderboard, _notifications, _marketplace),
      ]);
      final tabs = buildHubTabs(
        results[0] as Map<String, bool>,
        results[1] as Map<String, int>,
      );
      await writeHubSnapshot(
        flags: Map<String, bool>.from(results[0] as Map<String, bool>),
        counts: Map<String, int>.from(results[1] as Map<String, int>),
      );
      if (!mounted) return;
      setState(() {
        _tabs = tabs;
        _pages = tabs.map((t) => t.build()).toList(growable: false);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = hadTabs ? null : 'Impossible de préparer le hub pour le moment.';
        if (!hadTabs) {
          _tabs = const [];
          _pages = const [];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // Chargement initial plein écran uniquement (un rafraîchissement avec tabs déjà en
      // cache ne repasse jamais par cet état, cf. _loadModules) : le loader de marque est
      // donc à sa place ici, RuachSkeleton reste réservé aux rafraîchissements partiels.
      return Scaffold(
        appBar: const RuachAppBar(title: 'Hub'),
        body: const Center(child: RuachLoader(label: 'Préparation du hub')),
      );
    }
    if (_tabs.isEmpty) {
      return Scaffold(
        appBar: const RuachAppBar(title: 'Hub'),
        body: RuachEmptyState(
          icon: PhosphorIconsRegular.squaresFour,
          title: _error == null ? 'Aucune section active' : 'Hub indisponible',
          subtitle:
              _error ??
              'Les modules du hub sont désactivés ou indisponibles pour le moment.',
          actionLabel: 'Réessayer',
          onAction: _loadModules,
        ),
      );
    }
    return DefaultTabController(
      key: ValueKey(_tabs.map((e) => e.label).join('|')),
      length: _tabs.length,
      child: Scaffold(
        appBar: RuachAppBar(
          title: 'Hub',
          bottom: RuachTabBar(
            tabs: [for (final t in _tabs) Tab(child: HubTabTitle(tab: t))],
          ),
        ),
        body: TabBarView(children: _pages),
      ),
    );
  }
}
