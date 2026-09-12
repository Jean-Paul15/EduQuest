import 'dart:async';
import 'package:eduquest/app/widgets/boot_loading_screen.dart';
import 'package:eduquest/app/widgets/profile_load_error_view.dart';
import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/navigation/presentation/main_nav_page.dart';
import 'package:eduquest/features/profile/data/profile_setup_repository.dart';
import 'package:eduquest/features/profile/presentation/profile_setup_gate_page.dart';
import 'package:eduquest/features/session/data/device_session_service.dart';
import 'package:flutter/material.dart';

class LoggedInGate extends StatefulWidget {
  const LoggedInGate({
    super.key,
    required this.auth,
    required this.profileSetup,
    required this.session,
    required this.onThemeToggle,
    required this.themeMode,
    required this.gateVersion,
    required this.onProfileDone,
    required this.onSplashRemove,
  });
  final AuthRepository auth;
  final ProfileSetupRepository profileSetup;
  final DeviceSessionService session;
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;
  final int gateVersion;
  final VoidCallback onProfileDone;
  final VoidCallback onSplashRemove;

  @override
  State<LoggedInGate> createState() => _LoggedInGateState();
}

class _LoggedInGateState extends State<LoggedInGate> {
  late Future<bool> _sessionFuture;
  late Future<ProfileSetupState> _profileFuture;
  int _lastGateVersion = -1;
  bool _signOutQueued = false;

  @override
  void initState() {
    super.initState();
    _initFutures();
  }

  void _initFutures() {
    _sessionFuture = widget.session.ensureSingleDeviceSession().timeout(
      const Duration(seconds: 6),
      onTimeout: () => true,
    );
    _profileFuture = widget.profileSetup.load().timeout(
      const Duration(seconds: 8),
      onTimeout: _profileTimeout,
    );
    _lastGateVersion = widget.gateVersion;
  }

  Future<ProfileSetupState> _profileTimeout() async {
    final cached = await widget.profileSetup.loadCached();
    if (cached?.complete == true) return cached!;
    throw TimeoutException('Profile verification timed out');
  }

  void _retryProfile() => setState(_initFutures);

  void _queueSignOut() {
    if (_signOutQueued) return;
    _signOutQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.auth.signOut();
    });
  }

  @override
  void didUpdateWidget(covariant LoggedInGate old) {
    super.didUpdateWidget(old);
    if (widget.gateVersion != _lastGateVersion) {
      _initFutures();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _sessionFuture,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const BootLoadingScreen();
        }
        if (snap.data == false) {
          _queueSignOut();
          return const BootLoadingScreen();
        }
        return FutureBuilder<ProfileSetupState>(
          future: _profileFuture,
          builder: (_, profileSnap) {
            if (profileSnap.connectionState == ConnectionState.waiting) {
              return const BootLoadingScreen();
            }
            if (profileSnap.hasError || !profileSnap.hasData) {
              widget.onSplashRemove();
              return ProfileLoadErrorView(onRetry: _retryProfile);
            }
            final state = profileSnap.data!;
            if (!state.complete) {
              widget.onSplashRemove();
              return ProfileSetupGatePage(onDone: widget.onProfileDone);
            }
            widget.onSplashRemove();
            return MainNavPage(
              onThemeToggle: widget.onThemeToggle,
              themeMode: widget.themeMode,
            );
          },
        );
      },
    );
  }
}
