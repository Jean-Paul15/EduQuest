import 'dart:async';
import 'package:eduquest/app/update_gate_handler.dart';
import 'package:eduquest/app/update_required_page.dart';
import 'package:eduquest/app/widgets/auth_gate_widget.dart';
import 'package:eduquest/app/widgets/boot_loading_screen.dart';
import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/app_config/data/update_gate_service.dart';
import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/navigation/presentation/main_nav_page.dart';
import 'package:eduquest/features/onboarding/data/onboarding_gate_service.dart';
import 'package:eduquest/features/onboarding/presentation/onboarding_intro_page.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:eduquest/shared/deeplink/app_deep_link_service.dart';
import 'package:eduquest/shared/realtime/content_realtime_service.dart';
import 'package:eduquest/shared/sync/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.onThemeToggle,
    required this.themeMode,
  });
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  final _auth = AuthRepository();
  final _config = AppConfigRepository();
  final _gate = UpdateGateService();
  final _onboarding = OnboardingGateService();
  final _deepLinks = AppDeepLinkService();
  UpdateGateResult _update = const UpdateGateResult(
    required: false,
    message: '',
    storeUrl: '',
  );
  int _gateVersion = 0;
  bool _seenOnboarding = false, _bootReady = false, _splashRemoved = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_deepLinks.start());
    _initBoot();
  }

  @override
  void dispose() {
    ServiceLocator().stop();
    unawaited(_deepLinks.stop());
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        AppAnalytics().track(
          'session_resumed',
          category: 'session',
          priority: 0,
        ),
      );
      unawaited(_refreshUpdateGate());
      unawaited(ContentRealtimeService.instance.resync());
      AppAnalytics().flushNow();
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      AppAnalytics().flushNow();
    }
  }

  Future<void> _initBoot() async {
    ServiceLocator().start();
    unawaited(
      AppAnalytics().track('session_open', category: 'session', priority: 0),
    );
    final seen = await _onboarding.isSeen();
    final result = await _refreshUpdateGate();
    if (!mounted) return;
    setState(() {
      _update = result;
      _seenOnboarding = seen;
      _bootReady = true;
    });
  }

  Future<UpdateGateResult> _refreshUpdateGate() async {
    UpdateGateResult r;
    try {
      r = await evaluateUpdateGate(config: _config, gate: _gate);
    } catch (_) {
      r = const UpdateGateResult(required: false, message: '', storeUrl: '');
    }
    if (mounted) setState(() => _update = r);
    return r;
  }

  void _removeSplashOnce() {
    if (_splashRemoved) return;
    FlutterNativeSplash.remove();
    _splashRemoved = true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_bootReady) return const BootLoadingScreen();
    if (_update.required) {
      _removeSplashOnce();
      return UpdateRequiredPage(
        message: _update.message,
        storeUrl: _update.storeUrl,
      );
    }
    if (!_seenOnboarding) {
      _removeSplashOnce();
      return OnboardingIntroPage(
        onContinue: () async {
          await _onboarding.markSeen();
          if (mounted) setState(() => _seenOnboarding = true);
        },
      );
    }
    if (!_auth.isConfigured) {
      _removeSplashOnce();
      return MainNavPage(
        onThemeToggle: widget.onThemeToggle,
        themeMode: widget.themeMode,
      );
    }
    return AuthGateWidget(
      auth: _auth,
      onThemeToggle: widget.onThemeToggle,
      themeMode: widget.themeMode,
      gateVersion: _gateVersion,
      onProfileDone: () => setState(() => _gateVersion++),
      onSplashRemove: _removeSplashOnce,
    );
  }
}
