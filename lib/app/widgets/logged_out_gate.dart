import 'package:eduquest/app/bootstrap/offline_session_gate.dart';
import 'package:eduquest/app/widgets/boot_loading_screen.dart';
import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/auth/presentation/login_page.dart';
import 'package:eduquest/features/navigation/presentation/main_nav_page.dart';
import 'package:flutter/material.dart';

class LoggedOutGate extends StatelessWidget {
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
  final VoidCallback onShowOfflineDialog;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: offlineGate.canEnterWithoutAuth(),
      builder: (_, off) {
        if (off.connectionState == ConnectionState.waiting) {
          return const BootLoadingScreen();
        }
        if (off.data == true) {
          onSplashRemove();
          return MainNavPage(onThemeToggle: onThemeToggle, themeMode: themeMode);
        }
        onShowOfflineDialog();
        onSplashRemove();
        return LoginPage(repository: auth);
      },
    );
  }
}
