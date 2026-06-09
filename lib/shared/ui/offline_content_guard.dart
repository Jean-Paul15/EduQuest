import 'dart:async';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/shared/network/network_probe.dart';
import 'package:eduquest/shared/ui/offline_bootstrap_alert.dart';
import 'package:flutter/material.dart';

/// Shows offline content warning if the device has no connection.
/// Returns true when a warning was actually shown.
Future<bool> guardOfflineContent({
  required BuildContext context,
  required String contentLabel,
}) async {
  final online = await NetworkProbe.hasConnection();
  if (online) return false;
  unawaited(NotificationService().sendOfflineContentWarning(contentLabel));
  // ignore: use_build_context_synchronously
  await showOfflineBootstrapAlert(context, contentLabel: contentLabel);
  return true;
}
