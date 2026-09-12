import 'package:eduquest/app/router/app_router.dart';
import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/features/engagement/presentation/contest_detail_page.dart';
import 'package:eduquest/features/engagement/presentation/event_detail_page.dart';
import 'package:eduquest/features/engagement/presentation/live_classes_page.dart';
import 'package:eduquest/features/engagement/presentation/surveys_page.dart';
import 'package:eduquest/features/surveys/presentation/survey_detail_page.dart';
import 'package:eduquest/features/learning/presentation/pages/chapter_course_page.dart';
import 'package:eduquest/features/learning/presentation/pages/exam_detail_page.dart';
import 'package:eduquest/features/learning/presentation/pages/qcm_attempt_page.dart';
import 'package:eduquest/features/learning/presentation/pages/quiz_intro_page.dart';
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
      path: 'quiz-intro/:quizId',
      name: AppRoutes.quizIntro,
      pageBuilder: (_, state) => slidePage(
        child: QuizIntroPage(
          quizId: state.pathParameters['quizId']!,
          title: state.uri.queryParameters['title'] ?? 'QCM',
          questionCount: int.tryParse(state.uri.queryParameters['questionCount'] ?? ''),
          timePerQuestionSeconds:
              int.tryParse(state.uri.queryParameters['timePerQuestionSeconds'] ?? ''),
          hasSavedProgress: state.uri.queryParameters['hasSavedProgress'] == 'true',
        ),
      ),
    ),
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
          subjectId: state.uri.queryParameters['subjectId'],
          subjectLabel: state.uri.queryParameters['subjectLabel'],
        ),
      ),
    ),
    // Cible des notifications de révision (mig 221) et de l'action assistant
    // `open_chapter` : auto-chargé, ne dépend que de l'id (cf ChapterCoursePage).
    GoRoute(
      path: 'chapter/:chapterId',
      name: AppRoutes.chapterCourse,
      pageBuilder: (_, state) => slidePage(
        child: ChapterCoursePage(
          chapterId: state.pathParameters['chapterId']!,
          chapterTitle: state.uri.queryParameters['title'] ?? 'Chapitre',
        ),
      ),
    ),
  ];
}
