import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/gamification/domain/daily_quest.dart';
import 'package:eduquest/features/gamification/domain/gamification_state.dart';
import 'package:eduquest/features/home/domain/home_snapshot.dart';
import 'package:eduquest/features/home/presentation/home_controller.dart';
import 'package:eduquest/features/home/presentation/widgets/home_body.dart';
import 'package:eduquest/features/home/presentation/widgets/home_body_shimmer.dart';
import 'package:eduquest/features/tickets/data/ticket_repository.dart';
import 'package:eduquest/features/tickets/presentation/ticket_activation_sheet.dart';
import 'package:eduquest/features/widget/data/home_widget_service.dart';
import 'package:eduquest/shared/external/web_checkout_handoff.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _HomePageState extends State<HomePage> {
  final _controller = HomeController();
  final _config = AppConfigRepository();
  final _widget = HomeWidgetService();
  final _handoff = WebCheckoutHandoff();
  String _supportUrl = '';
  String _displayName = 'Étudiant';
  AccessState _access = const AccessState(
    tier: 'FREE',
    hasAccess: true,
    expiresAt: null,
  );
  GamificationState _gam = const GamificationState(
    xp: 0,
    level: 1,
    streakDays: 0,
    bestStreak: 0,
  );
  List<DailyQuest> _quests = const [];
  bool _loadingHome = true;

  @override
  void initState() {
    super.initState();
    _config.loadAppLinks(forceRefresh: true).then((links) {
      if (!mounted) return;
      setState(() {
        _supportUrl = links['support_url'] ?? '';
      });
    });
    _controller.loadCachedSnapshot().then((s) {
      if (s != null) _applySnapshot(s);
    });
    _controller.initialize().then(_applySnapshot).catchError((_) {
      if (!mounted) return;
      setState(() => _loadingHome = false);
    });
    _controller.startRealtime(() => _controller.refresh().then(_applySnapshot));
  }

  @override
  void dispose() {
    _controller.stopRealtime();
    super.dispose();
  }

  Future<void> _claimCheckin() async {
    final message = await _controller.claimCheckin();
    if (!mounted) return;
    ModernSnackbar.show(context, message);
    _controller.track('daily_checkin_claimed');
    _controller.refresh().then(_applySnapshot);
  }

  Future<void> _refreshNow() async {
    final s = await _controller.refresh();
    _applySnapshot(s);
  }

  Future<void> _openExternal(String url, String fallback) async {
    final target = url.trim().isEmpty ? fallback : url.trim();
    if (target.isEmpty) {
      if (!mounted) return;
      ModernSnackbar.show(
        context,
        'Lien indisponible pour le moment.',
        success: false,
      );
      return;
    }
    bool ok = false;
    try {
      ok = await launchUrl(
        Uri.parse(target),
        mode: LaunchMode.inAppBrowserView,
      );
    } catch (_) {}
    if (!ok) {
      try {
        ok = await launchUrl(
          Uri.parse(target),
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {}
    }
    if (!ok && mounted) {
      ModernSnackbar.show(
        context,
        'Impossible d’ouvrir le lien pour le moment.',
        success: false,
      );
    }
  }

  Future<void> _openSupport() async {
    final launched = await _handoff.openSupport();
    if (launched) return;
    await _openExternal(_supportUrl, '');
  }

  Future<void> _openTicketCheckout() async {
    final launched = await _handoff.openTicketCheckout();
    if (launched) return;
    if (!mounted) return;
    ModernSnackbar.show(
      context,
      'Ouverture du paiement indisponible pour le moment.',
      success: false,
    );
  }

  (String, String, String?) _widgetFocus(HomeSnapshot s) {
    final pending = s.quests.where((q) => !q.completedToday).toList();
    if (pending.isNotEmpty) {
      final q = pending.first;
      return (
        'Défi du jour',
        '${q.label} • +${q.xpReward} XP',
        'Touchez pour ouvrir EduQuest',
      );
    }
    final exp = s.access.expiresAt;
    final d = exp?.difference(DateTime.now()).inDays;
    if (d != null && d <= 7) {
      return (
        'Ticket',
        '${s.access.tier} • Expire dans ${d < 0 ? 0 : d}j',
        'Touchez pour ouvrir EduQuest',
      );
    }
    if (s.gamification.streakDays > 0) {
      return (
        'Série active',
        '${s.gamification.streakDays} jours',
        'Touchez pour continuer',
      );
    }
    return (
      'Niveau',
      '${s.gamification.level} • ${s.gamification.xp} XP',
      'Touchez pour ouvrir EduQuest',
    );
  }

  void _applySnapshot(HomeSnapshot s) {
    if (!mounted) return;
    setState(() {
      _displayName = s.displayName;
      _access = s.access;
      _gam = s.gamification;
      _quests = s.quests;
      _loadingHome = false;
    });
    final (label, value, footer) = _widgetFocus(s);
    _widget.update(
      title: 'EduQuest • ${s.displayName}',
      focusLabel: label,
      focusValue: value,
      footer: footer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduQuest'),
        actions: [
          IconButton(
            onPressed: _openSupport,
            icon: const Icon(Icons.support_agent_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNow,
        child: Stack(
          children: [
            HomeBody(
              displayName: _displayName,
              access: _access,
              gamification: _gam,
              quests: _quests,
              onCheckin: _claimCheckin,
              onBuyTicket: _openTicketCheckout,
              onOpenTicket: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => TicketActivationSheet(
                  repository: TicketRepository(),
                  onBuyTicket: _openTicketCheckout,
                ),
              ),
            ),
            if (_loadingHome) const IgnorePointer(child: HomeBodyShimmer()),
          ],
        ),
      ),
    );
  }
}
