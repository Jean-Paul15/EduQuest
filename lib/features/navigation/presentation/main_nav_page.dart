import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:eduquest/features/engagement/data/hub_badge_repository.dart';
import 'package:eduquest/features/navigation/data/navigation_prefetch_service.dart';
import 'package:eduquest/features/navigation/presentation/widgets/main_nav_bar.dart';
import 'package:eduquest/features/navigation/presentation/widgets/main_nav_body.dart';
import 'dart:async';

import 'package:eduquest/features/assistant/domain/assistant_seed.dart';
import 'package:eduquest/features/assistant/presentation/assistant_seed_bus.dart';
import 'package:eduquest/shared/deeplink/app_deep_link_command.dart';
import 'package:eduquest/shared/realtime/cache_invalidation_bus.dart';
import 'package:eduquest/shared/realtime/cache_signal.dart';
import 'package:eduquest/shared/sync/scope_refresh_bus.dart';
import 'package:eduquest/shared/sync/service_locator.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavPage extends StatefulWidget {
  const MainNavPage({
    super.key,
    required this.onThemeToggle,
    required this.themeMode,
    this.tabBuilders,
  });
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;
  final List<WidgetBuilder>? tabBuilders;
  @override
  State<MainNavPage> createState() => _MainNavPageState();
}

class _MainNavPageState extends State<MainNavPage> {
  int _index = 0, _hubBadge = 0, _scopeRev = 0;
  final _badgeRepo = HubBadgeRepository();
  final _prefetch = NavigationPrefetchService();
  StreamSubscription<CacheSignal>? _invalidationSub;
  // Pas de bandeau permanent : l'app fonctionne hors ligne par design. On
  // avertit une seule fois par panne — uniquement quand l'appareil a du
  // réseau mais que le backend lui-même ne répond pas à nos tentatives —
  // via une notification ponctuelle en bas d'écran, jamais pour une simple
  // coupure réseau (état normal, déjà géré par le mode hors-ligne).
  bool _backendDownNoticeShown = false;

  void _clearFocus() => FocusManager.instance.primaryFocus?.unfocus();

  @override
  void initState() {
    super.initState();
    _loadBadge();
    Future<void>.microtask(() async {
      await _prefetch.tab(0);
      await Future<void>.delayed(const Duration(milliseconds: 350));
      await _prefetch.neighbors(0);
    });
    ScopeRefreshBus.listenable.addListener(_onScopeChanged);
    AppDeepLinkBus.notifier.addListener(_onDeepLinkCommand);
    _invalidationSub = CacheInvalidationBus.instance.stream.listen((s) {
      if (s.isScopeReset || s.namespace.startsWith('hub')) {
        Future<void>.microtask(_loadBadge);
      }
    });
    ServiceLocator().notifier.addListener(_onBackendReachabilityChanged);
    // Un push ouvert avant que cet écran ne soit monté (démarrage à froid)
    // laisse sa valeur dans le bus sans déclencher le listener — même angle
    // mort que AssistantSeedBus (déjà géré via AiAssistantPage._boot()) : on
    // draine explicitement la valeur déjà présente au montage.
    Future<void>.microtask(_onDeepLinkCommand);
  }

  @override
  void dispose() {
    ScopeRefreshBus.listenable.removeListener(_onScopeChanged);
    AppDeepLinkBus.notifier.removeListener(_onDeepLinkCommand);
    _invalidationSub?.cancel();
    ServiceLocator().notifier.removeListener(_onBackendReachabilityChanged);
    super.dispose();
  }

  void _onBackendReachabilityChanged() {
    final oracle = ServiceLocator().oracle;
    final backendUnreachable = oracle.hasDeviceNetwork && ServiceLocator().notifier.isOffline;
    if (backendUnreachable) {
      if (_backendDownNoticeShown || !mounted) return;
      _backendDownNoticeShown = true;
      RuachSnackbar.error(
        context,
        'Le service ne répond pas — on est peut-être en maintenance, réessaie dans un instant.',
      );
    } else {
      _backendDownNoticeShown = false;
    }
  }

  Future<void> _loadBadge() async {
    final n = await _badgeRepo.unseenCount();
    if (mounted) setState(() => _hubBadge = n);
  }

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
    _clearFocus();
    if (cmd.tabIndex != null) {
      setState(() => _index = cmd.tabIndex!);
      Future<void>.microtask(() => _prefetch.tab(_index));
      Future<void>.microtask(() => _prefetch.neighbors(_index));
    }
    if (cmd.message.isNotEmpty) {
      ModernSnackbar.show(context, cmd.message, success: cmd.success);
    }
    if (cmd.entityId.isNotEmpty) {
      Future<void>.microtask(() => _openDeepLinkDetails(cmd));
    }
    Future<void>.microtask(_loadBadge);
    AppDeepLinkBus.clear();
  }

  Future<void> _openDeepLinkDetails(AppDeepLinkCommand cmd) async {
    if (!mounted) return;
    final kind = cmd.kind;
    final id = cmd.entityId;
    if (kind == 'event') {
      await context.push('/event/$id');
      return;
    }
    if (kind == 'contest') {
      await context.push('/contest/$id');
      return;
    }
    // Rappel de révision (mig 221) ou action assistant `open_chapter`.
    if (kind == 'chapter') {
      await context.push('/chapter/$id');
      return;
    }
    // Notification ciblée composée par l'IA (mig 227) : au lieu d'ouvrir le
    // chapitre en lecture statique, on lance une conversation avec l'assistant
    // — il a déjà la mémoire de l'élève (méprises, maîtrise) injectée à chaque
    // tour, donc il peut reprendre directement la difficulté et discuter,
    // pas juste renvoyer vers un cours figé.
    if (kind == 'assistant_seed') {
      final label = Uri.decodeComponent(cmd.params['label'] ?? '');
      final subjectId = cmd.params['subject'];
      // `presentDirectly` : l'élève n'a rien tapé, c'est la notification qui
      // relance ce point précis — pas de bulle "élève" fabriquée qui lui
      // ferait dire une phrase qu'il n'a jamais écrite ; seule la réponse de
      // l'assistant s'affiche, comme s'il reprenait lui-même la conversation.
      final prompt = label.isEmpty
          ? 'Reprenons ce chapitre ensemble : explique-le clairement, étape par étape.'
          : 'On reprend ce point précis : $label. Explique-le clairement, étape par étape, comme si tu relançais la conversation toi-même.';
      AssistantSeedBus.emit(AssistantSeed(prompt: prompt, subjectId: subjectId, presentDirectly: true));
    }
  }

  Future<void> _onNavTap(int value) async {
    _clearFocus();
    if (_index == value) {
      Future<void>.microtask(() => _prefetch.tab(value));
      return;
    }
    setState(() => _index = value);
    Future<void>.microtask(() => _prefetch.tab(value));
    Future<void>.microtask(() => _prefetch.neighbors(value));
    Future<void>.microtask(_loadBadge);
  }

  Future<bool> _onWillPop() async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Quitter RuachEdu ?'),
        content: const Text('Tu es sûr de vouloir fermer l\'application ?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Rester'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await _onWillPop();
        if (shouldExit && mounted) {
          // Force app to background — Android convention for exit
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: MainNavBody(
          index: _index,
          scopeRev: _scopeRev,
          onThemeToggle: widget.onThemeToggle,
          themeMode: widget.themeMode,
          tabBuilders: widget.tabBuilders,
        ),
        bottomNavigationBar: MainNavBar(
          selectedIndex: _index,
          hubBadge: _hubBadge,
          onDestinationSelected: _onNavTap,
        ),
      ),
    );
  }
}
