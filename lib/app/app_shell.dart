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
import 'package:flutter/material.dart';

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

class _AppShellState extends State<AppShell> {
  final _auth = AuthRepository();
  final _config = AppConfigRepository();
  final _gate = UpdateGateService();
  final _onboarding = OnboardingGateService();
  final _session = DeviceSessionService();
  final _profileSetup = ProfileSetupRepository();
  final _offlineGate = OfflineSessionGate();
  UpdateGateResult _update = const UpdateGateResult(
    required: false,
    message: '',
    storeUrl: '',
  );
  int _gateVersion = 0;
  bool _seenOnboarding = false;
  bool _bootReady = false;

  @override
  void initState() {
    super.initState();
    _initBoot();
  }

  Future<void> _initBoot() async {
    final seen = await _onboarding.isSeen();
    final policy = await _config.loadUpdatePolicy(_gate.platformKey());
    final result = await _gate.evaluate(policy);
    if (!mounted) return;
    setState(() {
      _update = result;
      _seenOnboarding = seen;
      _bootReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_bootReady) {
      return MainNavPage(
        onThemeToggle: widget.onThemeToggle,
        themeMode: widget.themeMode,
      );
    }
    if (_update.required) {
      return UpdateRequiredPage(
        message: _update.message,
        storeUrl: _update.storeUrl,
      );
    }
    if (!_seenOnboarding) {
      return OnboardingIntroPage(
        onContinue: () async {
          await _onboarding.markSeen();
          if (mounted) setState(() => _seenOnboarding = true);
        },
      );
    }
    if (!_auth.isConfigured) {
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
                return MainNavPage(
                  onThemeToggle: widget.onThemeToggle,
                  themeMode: widget.themeMode,
                );
              }
              if (off.data == true) {
                return MainNavPage(
                  onThemeToggle: widget.onThemeToggle,
                  themeMode: widget.themeMode,
                );
              }
              return LoginPage(repository: _auth);
            },
          );
        }
        unawaited(_offlineGate.markSeen());
        return FutureBuilder(
          future: _session.ensureSingleDeviceSession(),
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return MainNavPage(
                onThemeToggle: widget.onThemeToggle,
                themeMode: widget.themeMode,
              );
            }
            if (snap.data == false) {
              _auth.signOut();
              return const Center(child: CircularProgressIndicator());
            }
            return FutureBuilder(
              future: _profileSetup.load(),
              key: ValueKey(_gateVersion),
              builder: (_, profileSnap) {
                if (!profileSnap.hasData) {
                  return MainNavPage(
                    onThemeToggle: widget.onThemeToggle,
                    themeMode: widget.themeMode,
                  );
                }
                final state = profileSnap.data!;
                if (!state.complete) {
                  return ProfileSetupGatePage(
                    onDone: () => setState(() => _gateVersion++),
                  );
                }
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
