import 'package:eduquest/app/bootstrap/offline_session_gate.dart';
import 'package:eduquest/app/widgets/boot_loading_screen.dart';
import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/auth/presentation/login_page.dart';
import 'package:eduquest/features/navigation/presentation/main_nav_page.dart';
import 'package:eduquest/shared/network/network_probe.dart';
import 'package:flutter/material.dart';

class LoggedOutGate extends StatefulWidget {
  const LoggedOutGate({
    super.key,
    required this.auth,
    required this.offlineGate,
    required this.onThemeToggle,
    required this.themeMode,
    required this.onSplashRemove,
    required this.onShowOfflineDialog,
  });
  final AuthRepository auth;
  final OfflineSessionGate offlineGate;
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;
  final VoidCallback onSplashRemove;
  final ValueChanged<bool> onShowOfflineDialog;

  @override
  State<LoggedOutGate> createState() => _LoggedOutGateState();
}

class _LoggedOutGateState extends State<LoggedOutGate> {
  late final Future<Map<String, bool>> _gateFuture;
  bool _offlineDialogQueued = false;

  @override
  void initState() {
    super.initState();
    _gateFuture = _resolveGate();
  }

  Future<Map<String, bool>> _resolveGate() async {
    final seenUser = await widget.offlineGate.canEnterWithoutAuth();
    final hasBootstrap = await widget.offlineGate.hasOfflineBootstrapData();
    final online = await NetworkProbe.hasConnection();
    return {
      'allowOffline': seenUser && hasBootstrap && !online,
      'showOfflineNotice': !online && (!seenUser || !hasBootstrap),
      'missingCache': !online && seenUser && !hasBootstrap,
    };
  }

  void _queueOfflineDialog(bool missingCache) {
    if (_offlineDialogQueued) return;
    _offlineDialogQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onShowOfflineDialog(missingCache);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _gateFuture,
      builder: (_, off) {
        if (off.connectionState == ConnectionState.waiting) {
          return const BootLoadingScreen();
        }
        final gate = off.data ?? const <String, bool>{};
        if (gate['allowOffline'] == true) {
          widget.onSplashRemove();
          return MainNavPage(
            onThemeToggle: widget.onThemeToggle,
            themeMode: widget.themeMode,
          );
        }
        if (gate['showOfflineNotice'] == true) {
          _queueOfflineDialog(gate['missingCache'] == true);
        }
        widget.onSplashRemove();
        return LoginPage(repository: widget.auth);
      },
    );
  }
}
