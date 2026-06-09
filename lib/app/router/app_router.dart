import 'package:eduquest/app/app_shell.dart';
import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/features/engagement/presentation/contest_detail_page.dart';
import 'package:eduquest/features/engagement/presentation/event_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Central GoRouter configuration.
/// Shell route '/' hosts AppShell which handles auth/onboarding and shows MainNavPage.
/// Detail pages use Navigator.push (backward-compatible) or context.pushNamed.
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
          GoRoute(
            path: 'event/:eventId',
            name: AppRoutes.eventDetail,
            builder: (_, state) => EventDetailPage(
              id: state.pathParameters['eventId']!,
            ),
          ),
          GoRoute(
            path: 'contest/:contestId',
            name: AppRoutes.contestDetail,
            builder: (_, state) => ContestDetailPage(
              id: state.pathParameters['contestId']!,
            ),
          ),
        ],
      ),
    ],
  );
}
