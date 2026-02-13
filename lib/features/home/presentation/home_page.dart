import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/gamification/domain/daily_quest.dart';
import 'package:eduquest/features/gamification/domain/gamification_state.dart';
import 'package:eduquest/features/home/domain/home_snapshot.dart';
import 'package:eduquest/features/home/presentation/home_controller.dart';
import 'package:eduquest/features/home/presentation/widgets/home_body.dart';
import 'package:eduquest/features/tickets/data/ticket_repository.dart';
import 'package:eduquest/features/tickets/presentation/ticket_activation_sheet.dart';
import 'package:eduquest/features/widget/data/home_widget_service.dart';
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
  String _supportUrl = '';
  String _ticketShopUrl = '';
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

  @override
  void initState() {
    super.initState();
    _config.loadAppLinks().then((links) {
      if (!mounted) return;
      setState(() {
        _supportUrl = links['support_url'] ?? '';
        _ticketShopUrl = links['ticket_shop_url'] ?? '';
      });
    });
    _controller.loadCachedSnapshot().then((s) {
      if (s != null) _applySnapshot(s);
    });
    _controller.initialize().then(_applySnapshot);
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

  Future<void> _openExternal(String url, String fallback) async {
    final target = url.trim().isEmpty ? fallback : url.trim();
    if (target.isEmpty) {
      if (!mounted) return;
      ModernSnackbar.show(
        context,
        'Lien non configure cote backend.',
        success: false,
      );
      return;
    }
    await launchUrl(Uri.parse(target), mode: LaunchMode.externalApplication);
  }

  (String, String, String?) _widgetFocus(HomeSnapshot s) {
    final exp = s.access.expiresAt;
    final d = exp?.difference(DateTime.now()).inDays;
    if (d != null && d <= 7) {
      return (
        'Ticket',
        '${s.access.tier} • Expire dans ${d < 0 ? 0 : d}j',
        'Renouvelle bientôt',
      );
    }
    if (s.gamification.streakDays > 0) {
      return ('Série', '${s.gamification.streakDays} jours', null);
    }
    return (
      'Niveau',
      '${s.gamification.level} • ${s.gamification.xp} XP',
      null,
    );
  }

  void _applySnapshot(HomeSnapshot s) {
    if (!mounted) return;
    setState(() {
      _displayName = s.displayName;
      _access = s.access;
      _gam = s.gamification;
      _quests = s.quests;
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
            onPressed: () => _openExternal(_supportUrl, ''),
            icon: const Icon(Icons.support_agent_rounded),
          ),
        ],
      ),
      body: HomeBody(
        displayName: _displayName,
        access: _access,
        gamification: _gam,
        quests: _quests,
        onCheckin: _claimCheckin,
        onBuyTicket: () => _openExternal(_ticketShopUrl, ''),
        onOpenTicket: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => TicketActivationSheet(
            repository: TicketRepository(),
            onBuyTicket: () => _openExternal(_ticketShopUrl, ''),
          ),
        ),
      ),
    );
  }
}
