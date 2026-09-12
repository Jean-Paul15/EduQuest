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
import 'package:url_launcher/url_launcher.dart';

/// Ouvre une vidéo : bascule vers l'app YouTube pour les vidéos YouTube
/// (aucune détection fiable d'une vidéo à l'intégration restreinte n'est
/// possible côté client — l'erreur "video unavailable" vient de l'iframe
/// YouTube lui-même, pas d'une erreur réseau interceptable), lecteur interne
/// sinon. Partagé entre l'ouverture d'une ressource de cours et la liste de
/// vidéos dédiée.
Future<void> openVideoResource(
  BuildContext context, {
  required String title,
  required String url,
}) async {
  final yt = isYoutubeUrl(url);
  final id = yt ? parseYoutubeId(url) : null;
  if (id != null) {
    await launchUrl(
      Uri.parse('https://youtu.be/$id'),
      mode: LaunchMode.externalApplication,
    );
    return;
  }
  if (!context.mounted) return;
  await context.pushNamed(AppRoutes.mediaPlayer, queryParameters: {
    'title': title, 'url': url, 'isYoutube': yt.toString(),
  });
}

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
    await openVideoResource(context, title: r.title, url: r.url);
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
