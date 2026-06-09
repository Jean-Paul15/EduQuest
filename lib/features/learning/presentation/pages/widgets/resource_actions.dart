import 'dart:async';
import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/features/gamification/data/gamification_repository.dart';
import 'package:eduquest/features/learning/domain/chapter_resource.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/shared/network/network_probe.dart';
import 'package:eduquest/shared/ui/media/youtube_url_parser.dart';
import 'package:eduquest/shared/ui/offline_bootstrap_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<void> openResource(
  BuildContext context,
  ChapterResource r, {
  required bool isPdfMode,
  required bool isVideoMode,
  required String emptyLabel,
}) async {
  unawaited(GamificationRepository().claimQuestByCode('open_lesson'));
  if (isPdfMode) {
    await context.pushNamed(AppRoutes.pdfViewer, queryParameters: {
      'title': r.title, 'url': r.url, 'emptyLabel': emptyLabel,
    });
    return;
  }
  if (isVideoMode) {
    final yt = isYoutubeUrl(r.url);
    await context.pushNamed(AppRoutes.mediaPlayer, queryParameters: {
      'title': r.title, 'url': r.url, 'isYoutube': yt.toString(),
    });
    return;
  }
  await context.pushNamed(AppRoutes.webView, queryParameters: {
    'title': r.title, 'url': r.url, 'emptyLabel': emptyLabel,
  });
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
