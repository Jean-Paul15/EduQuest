/// Route name constants and path definitions for RuachEdu go_router.
class AppRoutes {
  AppRoutes._();

  // ── Root ──
  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const login = 'login';
  static const main = 'main';

  // ── Main tabs ──
  static const home = 'home';
  static const feed = 'feed';
  static const learning = 'learning';
  static const hub = 'hub';
  static const profile = 'profile';

  // ── Learning sub-routes ──
  static const subjectSection = 'subject-section';
  static const chapterList = 'chapter-list';
  static const chapterCourse = 'chapter-course';
  static const chapterMedia = 'chapter-media';
  static const chapterQuizList = 'chapter-quiz-list';
  static const chapterResourceList = 'chapter-resource-list';
  static const resourceLearning = 'resource-learning';
  static const qcmAttempt = 'qcm-attempt';
  static const quizIntro = 'quiz-intro';
  static const examList = 'exam-list';
  static const examDetail = 'exam-detail';
  static const pdfLessons = 'pdf-lessons';

  // ── Engagement sub-routes ──
  static const events = 'events';
  static const eventDetail = 'event-detail';
  static const contests = 'contests';
  static const contestDetail = 'contest-detail';
  static const liveClasses = 'live-classes';
  static const surveys = 'surveys';
  static const surveyDetail = 'survey-detail';

  // ── Other feature routes ──
  static const leaderboard = 'leaderboard';
  static const marketplace = 'marketplace';
  static const marketplaceDetail = 'marketplace-detail';
  static const orientation = 'orientation';
  static const referral = 'referral';
  static const videos = 'videos';
  static const tickets = 'tickets';
  static const notifications = 'notifications';
  static const legal = 'legal';
  static const myData = 'my-data';
  static const protectedLesson = 'protected-lesson';
  static const profileSetup = 'profile-setup';
  static const mediaPlayer = 'media-player';
  static const pdfViewer = 'pdf-viewer';
  static const webView = 'web-view';

  // ── Paths ──
  static const path = '/';
  static const pathSubject = ':subjectId';
  static const pathChapter = ':chapterId';
  static const pathExam = ':examId';
  static const pathEvent = ':eventId';
  static const pathContest = ':contestId';
  static const pathResource = ':resourceId';
  static const pathQuiz = ':quizId';
  static const pathItem = ':itemId';
  static const pathSurvey = ':surveyId';
  static const pathDoc = ':docType';
  static const pathLesson = ':lessonId';
  static const pathMedia = ':mediaType/:mediaId';
}
