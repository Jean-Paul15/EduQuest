import 'dart:async';
import 'package:eduquest/app/update_required_page.dart';
import 'package:eduquest/app/bootstrap/offline_session_gate.dart';
import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/app_config/data/update_gate_service.dart';
import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/auth/presentation/login_page.dart';
import 'package:eduquest/features/navigation/presentation/main_nav_page.dart';
import 'package:eduquest/features/onboarding/data/onboarding_gate_service.dart';
import 'package:eduquest/features/onboarding/presentation/onboarding_intro_page.dart';
import 'package:eduquest/features/profile/data/profile_setup_repository.dart';
import 'package:eduquest/features/profile/presentation/profile_setup_gate_page.dart';
import 'package:eduquest/features/session/data/device_session_service.dart';
import 'package:eduquest/shared/deeplink/app_deep_link_service.dart';
import 'package:eduquest/shared/network/network_probe.dart';
import 'package:flutter/cupertino.dart';
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
  final _session = DeviceSessionService();
  final _profileSetup = ProfileSetupRepository();
  final _offlineGate = OfflineSessionGate();
  final _deepLinks = AppDeepLinkService();
  UpdateGateResult _update = const UpdateGateResult(
    required: false,
    message: '',
    storeUrl: '',
  );
  int _gateVersion = 0;
  bool _seenOnboarding = false;
  bool _bootReady = false;
  bool _splashRemoved = false;
  bool _offlineNoticeOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_deepLinks.start());
    _initBoot();
  }

  @override
  void dispose() {
    unawaited(_deepLinks.stop());
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshUpdateGate());
    }
  }

  Future<void> _initBoot() async {
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
    try {
      final policy = await _config.loadUpdatePolicy(_gate.platformKey());
      var result = await _gate.evaluate(policy);
      if (result.required) {
        final online = await NetworkProbe.hasConnection();
        if (!online) {
          result = const UpdateGateResult(
            required: false,
            message: '',
            storeUrl: '',
          );
        }
      }
      if (mounted) {
        setState(() => _update = result);
      }
      return result;
    } catch (_) {
      const result = UpdateGateResult(
        required: false,
        message: '',
        storeUrl: '',
      );
      if (mounted) {
        setState(() => _update = result);
      }
      return result;
    }
  }

  Widget _bootLoading() {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7FAFF), Color(0xFFF2F6FF)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school_rounded, size: 42, color: Color(0xFF1D5EFF)),
              SizedBox(height: 10),
              Text('EduQuest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              SizedBox(height: 16),
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeSplashOnce() {
    if (_splashRemoved) return;
    FlutterNativeSplash.remove();
    _splashRemoved = true;
  }

  Future<void> _maybeShowOfflineFirstOpenDialog() async {
    if (_offlineNoticeOpen || !mounted) return;
    final online = await NetworkProbe.hasConnection();
    if (online || !mounted) return;
    final once = await _offlineGate.consumeNoCacheNotice();
    if (!once || !mounted) return;
    _offlineNoticeOpen = true;
    unawaited(
      showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Connexion requise une première fois'),
          content: const Text(
            'Ouvre l’application une première fois avec Internet, puis tu pourras continuer plus facilement hors connexion.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Compris'),
            ),
          ],
        ),
      ).whenComplete(() => _offlineNoticeOpen = false),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_bootReady) {
      return _bootLoading();
    }
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
    return StreamBuilder(
      stream: _auth.authStream,
      builder: (_, __) {
        final user = _auth.currentUser;
        if (user == null) {
          return FutureBuilder(
            future: _offlineGate.canEnterWithoutAuth(),
            builder: (_, off) {
              if (off.connectionState == ConnectionState.waiting) {
                return _bootLoading();
              }
              if (off.data == true) {
                _removeSplashOnce();
                return MainNavPage(
                  onThemeToggle: widget.onThemeToggle,
                  themeMode: widget.themeMode,
                );
              }
              unawaited(_maybeShowOfflineFirstOpenDialog());
              _removeSplashOnce();
              return LoginPage(repository: _auth);
            },
          );
        }
        unawaited(_offlineGate.markSeen());
        return FutureBuilder(
          future: _session.ensureSingleDeviceSession(),
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return _bootLoading();
            }
            if (snap.data == false) {
              _auth.signOut();
              return _bootLoading();
            }
            return FutureBuilder(
              future: _profileSetup.load(),
              key: ValueKey(_gateVersion),
              builder: (_, profileSnap) {
                if (profileSnap.connectionState == ConnectionState.waiting) {
                  return _bootLoading();
                }
                if (profileSnap.hasError || !profileSnap.hasData) {
                  _removeSplashOnce();
                  return MainNavPage(
                    onThemeToggle: widget.onThemeToggle,
                    themeMode: widget.themeMode,
                  );
                }
                final state = profileSnap.data!;
                if (!state.complete) {
                  _removeSplashOnce();
                  return ProfileSetupGatePage(
                    onDone: () => setState(() => _gateVersion++),
                  );
                }
                _removeSplashOnce();
                return MainNavPage(
                  onThemeToggle: widget.onThemeToggle,
                  themeMode: widget.themeMode,
                );
              },
            );
          },
        );
      },
    );
  }
}
