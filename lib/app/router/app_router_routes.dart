import 'package:eduquest/app/router/app_router.dart';
import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/features/engagement/presentation/contest_detail_page.dart';
import 'package:eduquest/features/engagement/presentation/event_detail_page.dart';
import 'package:eduquest/features/engagement/presentation/live_classes_page.dart';
import 'package:eduquest/features/engagement/presentation/surveys_page.dart';
import 'package:eduquest/features/surveys/presentation/survey_detail_page.dart';
import 'package:eduquest/features/learning/presentation/pages/exam_detail_page.dart';
import 'package:eduquest/features/learning/presentation/pages/qcm_attempt_page.dart';
import 'package:go_router/go_router.dart';

/// Engagement and learning sub-routes for the root GoRoute.
List<RouteBase> buildAppRoutes() {
  return [
    // ── Engagement ──
    GoRoute(
      path: 'event/:eventId',
      name: AppRoutes.eventDetail,
      pageBuilder: (_, state) => slidePage(
        child: EventDetailPage(id: state.pathParameters['eventId']!),
      ),
    ),
    GoRoute(
      path: 'contest/:contestId',
      name: AppRoutes.contestDetail,
      pageBuilder: (_, state) => slidePage(
        child: ContestDetailPage(id: state.pathParameters['contestId']!),
      ),
    ),
    GoRoute(
      path: 'live-classes',
      name: AppRoutes.liveClasses,
      pageBuilder: (_, __) => slidePage(child: const LiveClassesPage()),
    ),
    GoRoute(
      path: 'surveys',
      name: AppRoutes.surveys,
      pageBuilder: (_, __) => slidePage(child: const SurveysPage()),
    ),
    GoRoute(
      path: 'survey/:surveyId',
      name: AppRoutes.surveyDetail,
      pageBuilder: (_, state) => slidePage(
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
      pageBuilder: (_, state) => slidePage(
        child: QcmAttemptPage(
          quizId: state.pathParameters['quizId']!,
          title: state.uri.queryParameters['title'] ?? 'QCM',
        ),
      ),
    ),
    GoRoute(
      path: 'exam-detail',
      name: AppRoutes.examDetail,
      pageBuilder: (_, state) => slidePage(
        child: ExamDetailPage(
          title: state.uri.queryParameters['title'] ?? 'Épreuve',
          paperUrl: state.uri.queryParameters['paperUrl']!,
          correctionUrl: state.uri.queryParameters['correctionUrl'],
        ),
      ),
    ),
  ];
}
