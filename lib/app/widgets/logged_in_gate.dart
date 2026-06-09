import 'package:eduquest/app/widgets/boot_loading_screen.dart';
import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/navigation/presentation/main_nav_page.dart';
import 'package:eduquest/features/profile/data/profile_setup_repository.dart';
import 'package:eduquest/features/profile/presentation/profile_setup_gate_page.dart';
import 'package:eduquest/features/session/data/device_session_service.dart';
import 'package:flutter/material.dart';

class LoggedInGate extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: session.ensureSingleDeviceSession(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const BootLoadingScreen();
        if (snap.data == false) {
          auth.signOut();
          return const BootLoadingScreen();
        }
        return FutureBuilder(
          future: profileSetup.load(),
          key: ValueKey(gateVersion),
          builder: (_, profileSnap) {
            if (profileSnap.connectionState == ConnectionState.waiting) {
              return const BootLoadingScreen();
            }
            if (profileSnap.hasError || !profileSnap.hasData) {
              onSplashRemove();
              return MainNavPage(onThemeToggle: onThemeToggle, themeMode: themeMode);
            }
            final state = profileSnap.data!;
            if (!state.complete) {
              onSplashRemove();
              return ProfileSetupGatePage(onDone: onProfileDone);
            }
            onSplashRemove();
            return MainNavPage(onThemeToggle: onThemeToggle, themeMode: themeMode);
          },
        );
      },
    );
  }
}
