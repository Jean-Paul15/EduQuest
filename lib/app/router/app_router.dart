import 'package:eduquest/app/app_shell.dart';
import 'package:eduquest/app/router/app_router_extra_routes.dart';
import 'package:eduquest/app/router/app_router_routes.dart';
import 'package:eduquest/app/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Central GoRouter configuration for RuachEdu.
///
/// Route `/` hosts AppShell (auth/onboarding → MainNavPage with 5-tab IndexedStack).
/// Detail pages push on top as sub-routes with custom slide transitions.
/// Pages that receive complex domain objects (ChapterListPage, ChapterCoursePage,
/// MarketplaceItemDetailPage, etc.) keep using Navigator.push — go_router's `extra`
/// would lose type safety.
GoRouter appRouter({
  required VoidCallback onThemeToggle,
  required ThemeMode themeMode,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: AppRoutes.splash,
        pageBuilder: (_, __) => NoTransitionPage(
          child: AppShell(
            onThemeToggle: onThemeToggle,
            themeMode: themeMode,
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
