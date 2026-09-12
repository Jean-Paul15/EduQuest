import 'package:eduquest/app/router/app_router.dart';
import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/features/leaderboard/presentation/leaderboard_page.dart';
import 'package:eduquest/features/legal/presentation/legal_document_page.dart';
import 'package:eduquest/features/marketplace/presentation/marketplace_page.dart';
import 'package:eduquest/features/notifications/presentation/user_notifications_page.dart';
import 'package:eduquest/features/orientation/presentation/orientation_page.dart';
import 'package:eduquest/features/privacy/presentation/pages/my_data_page.dart';
import 'package:eduquest/features/referral/presentation/referral_page.dart';
import 'package:eduquest/features/tickets/presentation/pages/tickets_page.dart';
import 'package:eduquest/features/videos/presentation/videos_page.dart';
import 'package:eduquest/shared/ui/media/app_media_player_page.dart';
import 'package:eduquest/shared/ui/pdf/app_pdf_viewer_page.dart';
import 'package:eduquest/shared/ui/web/app_webview_page.dart';
import 'package:go_router/go_router.dart';

/// Media viewers and general feature sub-routes for the root GoRoute.
List<RouteBase> buildExtraRoutes() {
  return [
    // ── Media / Viewers ──
    GoRoute(
      path: 'media',
      name: AppRoutes.mediaPlayer,
      pageBuilder: (_, state) => slidePage(
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
      pageBuilder: (_, state) => slidePage(
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
      pageBuilder: (_, state) => slidePage(
        child: AppWebViewPage(
          title: state.uri.queryParameters['title'] ?? '',
          url: state.uri.queryParameters['url']!,
          emptyLabel: state.uri.queryParameters['emptyLabel'] ?? 'Page indisponible',
        ),
      ),
    ),

    // ── Feature pages (no constructor params) ──
    GoRoute(path: 'leaderboard', name: AppRoutes.leaderboard, pageBuilder: (_, __) => slidePage(child: const LeaderboardPage())),
    GoRoute(path: 'marketplace', name: AppRoutes.marketplace, pageBuilder: (_, __) => slidePage(child: const MarketplacePage())),
    GoRoute(path: 'tickets', name: AppRoutes.tickets, pageBuilder: (_, __) => slidePage(child: const TicketsPage())),
    GoRoute(path: 'notifications', name: AppRoutes.notifications, pageBuilder: (_, __) => slidePage(child: const UserNotificationsPage())),
    GoRoute(path: 'referral', name: AppRoutes.referral, pageBuilder: (_, __) => slidePage(child: const ReferralPage())),
    GoRoute(path: 'orientation', name: AppRoutes.orientation, pageBuilder: (_, __) => slidePage(child: const OrientationPage())),
    GoRoute(path: 'videos', name: AppRoutes.videos, pageBuilder: (_, __) => slidePage(child: const VideosPage())),
    GoRoute(path: 'my-data', name: AppRoutes.myData, pageBuilder: (_, __) => slidePage(child: const MyDataPage())),
    GoRoute(
      path: 'legal/:docType',
      name: AppRoutes.legal,
      pageBuilder: (_, state) => slidePage(
        child: LegalDocumentPage(docType: state.pathParameters['docType']!),
      ),
    ),
  ];
}
