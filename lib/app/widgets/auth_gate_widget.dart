import 'dart:async';
import 'package:eduquest/app/bootstrap/offline_session_gate.dart';
import 'package:eduquest/app/widgets/logged_in_gate.dart';
import 'package:eduquest/app/widgets/logged_out_gate.dart';
import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/profile/data/profile_setup_repository.dart';
import 'package:eduquest/features/session/data/device_session_service.dart';
import 'package:eduquest/shared/network/network_probe.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthGateWidget extends StatefulWidget {
  const AuthGateWidget({
    super.key,
    required this.auth,
    required this.onThemeToggle,
    required this.themeMode,
    required this.gateVersion,
    required this.onProfileDone,
    required this.onSplashRemove,
  });
  final AuthRepository auth;
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;
  final int gateVersion;
  final VoidCallback onProfileDone;
  final VoidCallback onSplashRemove;

  @override
  State<AuthGateWidget> createState() => _AuthGateWidgetState();
}

class _AuthGateWidgetState extends State<AuthGateWidget> {
  final _profileSetup = ProfileSetupRepository();
  final _session = DeviceSessionService();
  final _offlineGate = OfflineSessionGate();
  bool _offlineNoticeOpen = false;

  Future<void> _showOfflineDialog() async {
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
            'Ouvre l\'application une première fois avec Internet, puis tu pourras continuer plus facilement hors connexion.',
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
    return StreamBuilder(
      stream: widget.auth.authStream,
      builder: (_, __) {
        final user = widget.auth.currentUser;
        if (user == null) {
          return LoggedOutGate(
            auth: widget.auth,
            offlineGate: _offlineGate,
            onThemeToggle: widget.onThemeToggle,
            themeMode: widget.themeMode,
            onSplashRemove: widget.onSplashRemove,
            onShowOfflineDialog: _showOfflineDialog,
          );
        }
        unawaited(_offlineGate.markSeen());
        return LoggedInGate(
          auth: widget.auth,
          profileSetup: _profileSetup,
          session: _session,
          onThemeToggle: widget.onThemeToggle,
          themeMode: widget.themeMode,
          gateVersion: widget.gateVersion,
          onProfileDone: widget.onProfileDone,
          onSplashRemove: widget.onSplashRemove,
        );
      },
    );
  }
}
