import 'package:eduquest/features/engagement/data/hub_badge_repository.dart';
import 'package:eduquest/features/navigation/data/navigation_prefetch_service.dart';
import 'package:eduquest/features/navigation/presentation/widgets/main_nav_bar.dart';
import 'package:eduquest/features/navigation/presentation/widgets/main_nav_body.dart';
import 'package:eduquest/shared/deeplink/app_deep_link_command.dart';
import 'package:eduquest/shared/sync/realtime_auto_sync_service.dart';
import 'package:eduquest/shared/sync/scope_refresh_bus.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavPage extends StatefulWidget {
  const MainNavPage({super.key, required this.onThemeToggle, required this.themeMode});
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;
  @override
  State<MainNavPage> createState() => _MainNavPageState();
}

class _MainNavPageState extends State<MainNavPage> {
  int _index = 0, _hubBadge = 0, _scopeRev = 0;
  final _badgeRepo = HubBadgeRepository();
  final _prefetch = NavigationPrefetchService();
  late final RealtimeAutoSyncService _sync;

  @override
  void initState() {
    super.initState();
    _sync = RealtimeAutoSyncService(onSynced: _onSynced);
    _loadBadge();
    Future<void>.microtask(() async { await _prefetch.tab(0); await _prefetch.neighbors(0); });
    ScopeRefreshBus.listenable.addListener(_onScopeChanged);
    AppDeepLinkBus.notifier.addListener(_onDeepLinkCommand);
    _sync.start();
  }

  @override
  void dispose() {
    ScopeRefreshBus.listenable.removeListener(_onScopeChanged);
    AppDeepLinkBus.notifier.removeListener(_onDeepLinkCommand);
    _sync.stop();
    super.dispose();
  }

  void _onSynced() { if (mounted) { setState(() {}); Future<void>.microtask(_loadBadge); } }
  Future<void> _loadBadge() async { final n = await _badgeRepo.unseenCount(); if (mounted) setState(() => _hubBadge = n); }

  void _onScopeChanged() {
    if (!mounted) return;
    setState(() => _scopeRev++);
    Future<void>.microtask(() => _prefetch.tab(_index));
    Future<void>.microtask(() => _prefetch.neighbors(_index));
    Future<void>.microtask(_loadBadge);
  }

  void _onDeepLinkCommand() {
    final cmd = AppDeepLinkBus.notifier.value;
    if (!mounted || cmd == null) return;
    if (cmd.tabIndex != null) {
      setState(() => _index = cmd.tabIndex!);
      Future<void>.microtask(() => _prefetch.tab(_index));
      Future<void>.microtask(() => _prefetch.neighbors(_index));
    }
    if (cmd.message.isNotEmpty) ModernSnackbar.show(context, cmd.message, success: cmd.success);
    if (cmd.entityId.isNotEmpty) Future<void>.microtask(() => _openDeepLinkDetails(cmd.kind, cmd.entityId));
    Future<void>.microtask(_loadBadge);
    AppDeepLinkBus.clear();
  }

  Future<void> _openDeepLinkDetails(String kind, String id) async {
    if (!mounted) return;
    if (kind == 'event') { await context.push('/event/$id'); return; }
    if (kind == 'contest') await context.push('/contest/$id');
  }

  Future<void> _onNavTap(int value) async {
    if (_index == value) { Future<void>.microtask(() => _prefetch.tab(value)); return; }
    setState(() => _index = value);
    Future<void>.microtask(() => _prefetch.tab(value));
    Future<void>.microtask(() => _prefetch.neighbors(value));
    Future<void>.microtask(_loadBadge);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainNavBody(index: _index, scopeRev: _scopeRev, onThemeToggle: widget.onThemeToggle, themeMode: widget.themeMode),
      bottomNavigationBar: MainNavBar(selectedIndex: _index, hubBadge: _hubBadge, onDestinationSelected: _onNavTap),
    );
  }
}
