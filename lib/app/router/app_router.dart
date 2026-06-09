import 'package:eduquest/app/app_shell.dart';
import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/features/engagement/presentation/contest_detail_page.dart';
import 'package:eduquest/features/engagement/presentation/event_detail_page.dart';
import 'package:eduquest/features/engagement/presentation/live_classes_page.dart';
import 'package:eduquest/features/engagement/presentation/surveys_page.dart';
import 'package:eduquest/features/leaderboard/presentation/leaderboard_page.dart';
import 'package:eduquest/features/learning/presentation/pages/exam_detail_page.dart';
import 'package:eduquest/features/learning/presentation/pages/qcm_attempt_page.dart';
import 'package:eduquest/features/legal/presentation/legal_document_page.dart';
import 'package:eduquest/features/marketplace/presentation/marketplace_page.dart';
import 'package:eduquest/features/notifications/presentation/user_notifications_page.dart';
import 'package:eduquest/features/orientation/presentation/orientation_page.dart';
import 'package:eduquest/features/referral/presentation/referral_page.dart';
import 'package:eduquest/features/surveys/presentation/survey_detail_page.dart';
import 'package:eduquest/features/tickets/presentation/pages/tickets_page.dart';
import 'package:eduquest/features/videos/presentation/videos_page.dart';
import 'package:eduquest/shared/ui/media/app_media_player_page.dart';
import 'package:eduquest/shared/ui/pdf/app_pdf_viewer.dart';
import 'package:eduquest/shared/ui/web/app_webview_page.dart';
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
          // ── Engagement ──
          GoRoute(
            path: 'event/:eventId',
            name: AppRoutes.eventDetail,
            pageBuilder: (_, state) => _slidePage(
              child: EventDetailPage(id: state.pathParameters['eventId']!),
            ),
          ),
          GoRoute(
            path: 'contest/:contestId',
            name: AppRoutes.contestDetail,
            pageBuilder: (_, state) => _slidePage(
              child: ContestDetailPage(id: state.pathParameters['contestId']!),
            ),
          ),
          GoRoute(
            path: 'live-classes',
            name: AppRoutes.liveClasses,
            pageBuilder: (_, __) => _slidePage(child: const LiveClassesPage()),
          ),
          GoRoute(
            path: 'surveys',
            name: AppRoutes.surveys,
            pageBuilder: (_, __) => _slidePage(child: const SurveysPage()),
          ),
          GoRoute(
            path: 'survey/:surveyId',
            name: AppRoutes.surveyDetail,
            pageBuilder: (_, state) => _slidePage(
              child: SurveyDetailPage(
                id: state.pathParameters['surveyId']!,
                title: state.uri.queryParameters['title'] ?? 'Sondage',
              ),
            ),
          ),

          // ── Learning ──
          GoRoute(
            path: 'qcm-attempt/:quizId',
            name: AppRoutes.qcmAttempt,
            pageBuilder: (_, state) => _slidePage(
              child: QcmAttemptPage(
                quizId: state.pathParameters['quizId']!,
                title: state.uri.queryParameters['title'] ?? 'QCM',
              ),
            ),
          ),
          GoRoute(
            path: 'exam-detail',
            name: AppRoutes.examDetail,
            pageBuilder: (_, state) => _slidePage(
              child: ExamDetailPage(
                title: state.uri.queryParameters['title'] ?? 'Épreuve',
                paperUrl: state.uri.queryParameters['paperUrl']!,
                correctionUrl: state.uri.queryParameters['correctionUrl'],
              ),
            ),
          ),

          // ── Media / Viewers ──
          GoRoute(
            path: 'media',
            name: AppRoutes.mediaPlayer,
            pageBuilder: (_, state) => _slidePage(
              child: AppMediaPlayerPage(
                title: state.uri.queryParameters['title'] ?? 'Média',
                url: state.uri.queryParameters['url']!,
                isYoutube: state.uri.queryParameters['isYoutube'] == 'true',
              ),
            ),
          ),
          GoRoute(
            path: 'pdf',
            name: AppRoutes.pdfViewer,
            pageBuilder: (_, state) => _slidePage(
              child: AppPdfViewerPage(
                title: state.uri.queryParameters['title'] ?? 'PDF',
                url: state.uri.queryParameters['url']!,
                emptyLabel: state.uri.queryParameters['emptyLabel'] ?? 'Aucun contenu',
              ),
            ),
          ),
          GoRoute(
            path: 'web',
            name: AppRoutes.webView,
            pageBuilder: (_, state) => _slidePage(
              child: AppWebViewPage(
                title: state.uri.queryParameters['title'] ?? '',
                url: state.uri.queryParameters['url']!,
                emptyLabel: state.uri.queryParameters['emptyLabel'] ?? 'Page indisponible',
              ),
            ),
          ),

          // ── Feature pages (no constructor params) ──
          GoRoute(path: 'leaderboard', name: AppRoutes.leaderboard, pageBuilder: (_, __) => _slidePage(child: const LeaderboardPage())),
          GoRoute(path: 'marketplace', name: AppRoutes.marketplace, pageBuilder: (_, __) => _slidePage(child: const MarketplacePage())),
          GoRoute(path: 'tickets', name: AppRoutes.tickets, pageBuilder: (_, __) => _slidePage(child: const TicketsPage())),
          GoRoute(path: 'notifications', name: AppRoutes.notifications, pageBuilder: (_, __) => _slidePage(child: const UserNotificationsPage())),
          GoRoute(path: 'referral', name: AppRoutes.referral, pageBuilder: (_, __) => _slidePage(child: const ReferralPage())),
          GoRoute(path: 'orientation', name: AppRoutes.orientation, pageBuilder: (_, __) => _slidePage(child: const OrientationPage())),
          GoRoute(path: 'videos', name: AppRoutes.videos, pageBuilder: (_, __) => _slidePage(child: const VideosPage())),
          GoRoute(
            path: 'legal/:docType',
            name: AppRoutes.legal,
            pageBuilder: (_, state) => _slidePage(
              child: LegalDocumentPage(docType: state.pathParameters['docType']!),
            ),
          ),
        ],
      ),
    ],
  );
}

/// Custom slide transition: 280ms easeOutCubic push, 240ms easeInCubic pop.
CustomTransitionPage<void> _slidePage({required Widget child}) {
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
