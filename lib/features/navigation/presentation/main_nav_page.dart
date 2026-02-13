import 'package:eduquest/features/engagement/data/hub_badge_repository.dart';
import 'package:eduquest/features/engagement/presentation/engagement_hub_page.dart';
import 'package:eduquest/features/feed/presentation/feed_page.dart';
import 'package:eduquest/features/home/presentation/home_page.dart';
import 'package:eduquest/features/learning/presentation/learning_page.dart';
import 'package:eduquest/features/navigation/data/navigation_prefetch_service.dart';
import 'package:eduquest/features/navigation/presentation/widgets/nav_badge_icon.dart';
import 'package:eduquest/features/profile/presentation/profile_page.dart';
import 'package:eduquest/shared/sync/realtime_auto_sync_service.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class MainNavPage extends StatefulWidget {
  const MainNavPage({
    super.key,
    required this.onThemeToggle,
    required this.themeMode,
  });
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;
  @override
  State<MainNavPage> createState() => _MainNavPageState();
}

class _MainNavPageState extends State<MainNavPage> {
  int _index = 0, _hubBadge = 0;
  final _badgeRepo = HubBadgeRepository();
  final _prefetch = NavigationPrefetchService();
  late final RealtimeAutoSyncService _sync;

  @override
  void initState() {
    super.initState();
    _sync = RealtimeAutoSyncService(onSynced: _onSynced);
    _loadBadge();
    Future<void>.microtask(() async {
      await _prefetch.tab(0);
      await _prefetch.neighbors(0);
    });
    _sync.start();
  }

  @override
  void dispose() {
    _sync.stop();
    super.dispose();
  }

  void _onSynced() {
    if (!mounted) return;
    setState(() {});
    Future<void>.microtask(_loadBadge);
  }

  Future<void> _loadBadge() async {
    final n = await _badgeRepo.unseenCount();
    if (mounted) setState(() => _hubBadge = n);
  }

  Future<void> _onNavTap(int value) async {
    if (_index == value) {
      Future<void>.microtask(() => _prefetch.tab(value));
      return;
    }
    setState(() => _index = value);
    Future<void>.microtask(() => _prefetch.tab(value));
    Future<void>.microtask(() => _prefetch.neighbors(value));
    if (value == 3) {
      Future<void>.microtask(_badgeRepo.markSeenNow);
      setState(() => _hubBadge = 0);
      return;
    }
    Future<void>.microtask(_loadBadge);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomePage(
            onThemeToggle: widget.onThemeToggle,
            themeMode: widget.themeMode,
          ),
          const FeedPage(),
          const LearningPage(),
          const EngagementHubPage(),
          ProfilePage(
            onThemeToggle: widget.onThemeToggle,
            themeMode: widget.themeMode,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).navigationBarTheme.backgroundColor,
          border: const Border(
            top: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: _onNavTap,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Accueil',
            ),
            const NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded),
              label: 'Feed',
            ),
            const NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories_rounded),
              label: 'Apprendre',
            ),
            NavigationDestination(
              icon: NavBadgeIcon(
                icon: Icons.grid_view_outlined,
                count: _hubBadge,
              ),
              selectedIcon: NavBadgeIcon(
                icon: Icons.grid_view_rounded,
                count: _hubBadge,
              ),
              label: 'Hub',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
