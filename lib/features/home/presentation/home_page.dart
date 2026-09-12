import 'dart:async';
import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/gamification/domain/daily_quest.dart';
import 'package:eduquest/features/gamification/domain/gamification_state.dart';
import 'package:eduquest/features/home/domain/home_snapshot.dart';
import 'package:eduquest/features/home/presentation/helpers/home_navigation.dart';
import 'package:eduquest/features/home/presentation/helpers/home_snapshot.dart';
import 'package:eduquest/features/home/presentation/home_controller.dart';
import 'package:eduquest/features/home/presentation/widgets/home_app_bar.dart';
import 'package:eduquest/features/home/presentation/widgets/home_page_content.dart';
import 'package:eduquest/features/widget/data/home_widget_service.dart';
import 'package:eduquest/shared/external/web_checkout_handoff.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.onThemeToggle,
    required this.themeMode,
  });
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with HomeNavigationMixin {
  @override WebCheckoutHandoff get handoff => _handoff;
  @override String get supportUrl => _supportUrl;
  @override HomeController get controller => _controller;
  final _controller = HomeController();
  final _config = AppConfigRepository();
  final _widget = HomeWidgetService();
  final _handoff = WebCheckoutHandoff();
  String _supportUrl = '';
  String _displayName = 'Etudiant';
  AccessState _access = const AccessState(
    tier: 'FREE_LIGHT',
    hasAccess: true,
    expiresAt: null,
  );
  GamificationState _gam = const GamificationState(xp: 0, level: 1, streakDays: 0, bestStreak: 0);
  List<DailyQuest> _quests = const [];
  bool _loadingHome = true;
  @override
  void initState() {
    super.initState();
    unawaited(_bootstrapHome());
    _config.loadAppLinks().then((links) {
      if (!mounted) return;
      setState(() => _supportUrl = links['support_url'] ?? '');
    });
    _controller.startRealtime(() => _controller.refresh().then(applySnapshot));
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _bootstrapHome() async {
    try {
      final cached = await _controller.loadCachedSnapshot();
      if (cached != null) applySnapshot(cached);
      applySnapshot(await _controller.initialize());
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingHome = false);
    }
  }

  @override
  void applySnapshot(HomeSnapshot s) {
    if (!mounted) return;
    setState(() {
      _displayName = s.displayName;
      _access = s.access;
      _gam = s.gamification;
      _quests = s.quests;
      _loadingHome = false;
    });
    _widget.update(widgetPayload(s));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: HomeAppBar(onSupport: openSupport),
        body: HomePageContent(
          displayName: _displayName,
          access: _access,
          gamification: _gam,
          quests: _quests,
          loadingHome: _loadingHome,
          onRefresh: refreshNow,
          onCheckin: claimCheckin,
          onBuyTicket: openTicketCheckout,
          onOpenTicket: showActivationSheet,
        ),
      );
}
