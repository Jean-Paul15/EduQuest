import 'dart:async';
import 'package:eduquest/features/gamification/data/gamification_repository.dart';
import 'package:eduquest/features/learning/domain/chapter_resource.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/shared/network/network_probe.dart';
import 'package:eduquest/shared/ui/media/app_media_player_page.dart';
import 'package:eduquest/shared/ui/media/youtube_url_parser.dart';
import 'package:eduquest/shared/ui/offline_bootstrap_alert.dart';
import 'package:eduquest/shared/ui/pdf/app_pdf_viewer.dart';
import 'package:eduquest/shared/ui/web/app_webview_page.dart';
import 'package:flutter/material.dart';

Future<void> openResource(
  BuildContext context,
  ChapterResource r, {
  required bool isPdfMode,
  required bool isVideoMode,
  required String emptyLabel,
}) async {
  unawaited(GamificationRepository().claimQuestByCode('open_lesson'));
  if (isPdfMode) {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppPdfViewerPage(
          title: r.title,
          url: r.url,
          emptyLabel: emptyLabel,
        ),
      ),
    );
    return;
  }
  if (isVideoMode) {
    final yt = isYoutubeUrl(r.url);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AppMediaPlayerPage(title: r.title, url: r.url, isYoutube: yt),
      ),
    );
    return;
  }
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AppWebViewPage(
        title: r.title,
        url: r.url,
        emptyLabel: emptyLabel,
      ),
    ),
  );
}

Future<bool> warnIfOfflineBootstrap(
  BuildContext context, {
  required bool hadCache,
  required String label,
}) async {
  if (hadCache) return false;
  final online = await NetworkProbe.hasConnection();
  if (online || !context.mounted) return false;
  unawaited(NotificationService().sendOfflineContentWarning(label));
  await showOfflineBootstrapAlert(context, contentLabel: label);
  return true;
}
