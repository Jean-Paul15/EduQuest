import 'package:eduquest/app/app_shell.dart';
import 'package:eduquest/app/router/app_router_extra_routes.dart';
import 'package:eduquest/app/router/app_router_routes.dart';
import 'package:eduquest/shared/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Central GoRouter for RuachEdu.
///
/// Route `/` hosts AppShell (auth/onboarding → MainNavPage).
/// Detail pages push on top as sub-routes with custom slide transitions.
/// Uses `ValueNotifier<ThemeMode>` so the router itself is created once
/// and theme changes don't tear down the navigation tree.
GoRouter appRouter({
  required ValueNotifier<ThemeMode> themeNotifier,
  required VoidCallback onThemeToggle,
}) {
  return GoRouter(
    initialLocation: '/',
    navigatorKey: appNavigatorKey,
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (_, __) => NoTransitionPage(
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (_, mode, __) => AppShell(
              onThemeToggle: onThemeToggle,
              themeMode: mode,
            ),
          ),
        ),
        routes: [
          ...buildAppRoutes(),
          ...buildExtraRoutes(),
        ],
      ),
    ],
  );
}

/// Custom slide transition: 280ms easeOutCubic push, 240ms easeInCubic pop.
CustomTransitionPage<void> slidePage({required Widget child}) {
  return CustomTransitionPage<void>(
    child: child,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 240),
  );
}
