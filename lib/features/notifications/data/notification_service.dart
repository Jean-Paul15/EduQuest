import 'dart:async';
import 'package:eduquest/features/notifications/data/local_reminder_service.dart';
import 'package:eduquest/features/notifications/data/notification_preferences_repository.dart';
import 'package:eduquest/features/notifications/data/push_subscription_repository.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/deeplink/app_deep_link_command.dart';
import 'package:eduquest/shared/deeplink/app_deep_link_parser.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  static bool _initialized = false;
  static bool _handlersBound = false;
  final _local = LocalReminderService();
  final _pushRepo = PushSubscriptionRepository();
  final _analytics = AppAnalytics();

  Future<void> initialize() async {
    if (_initialized) return;
    await _local.initialize();
    if (Env.hasOneSignal) {
      OneSignal.Debug.setLogLevel(OSLogLevel.none);
      OneSignal.initialize(Env.oneSignalAppId);
      _bindHandlers();
      await _requestPermissionIfNeeded();
    }
    _initialized = true;
  }

  Future<void> syncUserContext({
    required String userId,
    required String country,
    required String level,
    required String serie,
    required String ticketTier,
    required NotificationPreferences prefs,
  }) async {
    await initialize();
    if (!Env.hasOneSignal) return;
    await OneSignal.login(userId);
    await OneSignal.User.setLanguage('fr');
    await OneSignal.User.addTags({
      'country': country,
      'level': level,
      'serie': serie,
      'ticket_tier': ticketTier,
      'topic_revision': '${prefs.revisionEnabled}',
      'topic_contest': '${prefs.contestEnabled}',
      'topic_event': '${prefs.eventEnabled}',
      'topic_live': '${prefs.eventEnabled}',
      'topic_survey': '${prefs.revisionEnabled}',
    });
    await _syncPushState(permissionGranted: OneSignal.Notifications.permission);
  }

  Future<void> setExternalUserId(String userId) async {
    if (!Env.hasOneSignal) return;
    await OneSignal.login(userId);
  }

  Future<void> clearExternalUserId() async {
    if (!Env.hasOneSignal) return;
    await OneSignal.logout();
  }

  Future<void> setLearningTags({
    required String country,
    required String level,
    required String serie,
  }) async {
    if (!Env.hasOneSignal) return;
    await OneSignal.User.addTags({
      'country': country,
      'level': level,
      'serie': serie,
      'topic_revision': 'true',
      'topic_contest': 'true',
      'topic_event': 'true',
    });
  }

  Future<void> setTopicTags({
    required bool revisionEnabled,
    required bool contestEnabled,
    required bool eventEnabled,
  }) async {
    if (!Env.hasOneSignal) return;
    await OneSignal.User.addTags({
      'topic_revision': '$revisionEnabled',
      'topic_contest': '$contestEnabled',
      'topic_event': '$eventEnabled',
      'topic_live': '$eventEnabled',
      'topic_survey': '$revisionEnabled',
    });
  }

  Future<void> syncDailyReminder({
    required NotificationPreferences prefs,
    required String displayName,
  }) async {
    await initialize();
    await _local.scheduleDaily(
      enabled: prefs.reminderEnabled,
      hour: prefs.reminderHour,
      minute: prefs.reminderMinute,
      displayName: displayName,
    );
  }

  Future<void> sendReminderPreview(String displayName) async {
    await initialize();
    await _local.showPreview(displayName);
  }

  Future<void> sendOfflineContentWarning(String contentLabel) async {
    await initialize();
    await _local.showInfo(
      title: 'Connexion requise',
      body: 'Active Internet pour charger $contentLabel la première fois.',
      id: 9403,
    );
  }

  Future<void> _requestPermissionIfNeeded() async {
    try {
      final canAsk = await OneSignal.Notifications.canRequest();
      if (canAsk) {
        await OneSignal.Notifications.requestPermission(false);
      }
    } catch (_) {}
  }

  void _bindHandlers() {
    if (_handlersBound || !Env.hasOneSignal) return;
    OneSignal.Notifications.addPermissionObserver((granted) {
      unawaited(_syncPushState(permissionGranted: granted));
    });
    OneSignal.User.pushSubscription.addObserver((state) {
      unawaited(
        _syncPushState(
          permissionGranted: OneSignal.Notifications.permission,
          subscriptionId: state.current.id ?? '',
          token: state.current.token ?? '',
          optedIn: state.current.optedIn,
        ),
      );
    });
    OneSignal.Notifications.addClickListener((event) {
      final title = event.notification.title ?? 'Notification RuachNova';
      final body = event.notification.body ?? '';
      final payload = _payload(event.notification.additionalData ?? {});
      payload['deeplink'] = payload['deeplink'] ??
          event.result.url ??
          event.notification.launchUrl ??
          '';
      _dispatchPayload(payload, body.isEmpty ? title : '$title • $body');
      unawaited(_analytics.track('push_clicked', payload: payload));
    });
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      final title = event.notification.title ?? 'Notification RuachNova';
      final body = event.notification.body ?? '';
      final payload = _payload(event.notification.additionalData ?? {});
      _dispatchPayload(payload, body.isEmpty ? title : '$title • $body');
      unawaited(_analytics.track('push_received', payload: payload));
    });
    _handlersBound = true;
  }

  Future<void> _syncPushState({
    required bool permissionGranted,
    String? subscriptionId,
    String? token,
    bool? optedIn,
  }) async {
    final sid = subscriptionId ?? OneSignal.User.pushSubscription.id ?? '';
    final tk = token ?? OneSignal.User.pushSubscription.token ?? '';
    final inFlag = optedIn ?? OneSignal.User.pushSubscription.optedIn ?? false;
    await _pushRepo.sync(
      subscriptionId: sid,
      token: tk,
      optedIn: inFlag,
      permissionGranted: permissionGranted,
    );
  }

  Map<String, dynamic> _payload(Map<dynamic, dynamic> raw) =>
      Map<String, dynamic>.from(raw);

  void _dispatchPayload(Map<String, dynamic> payload, String fallback) {
    final cmd = AppDeepLinkParser.fromNotificationPayload(
      payload,
      fallbackMessage: fallback,
    );
    if (cmd == null) return;
    AppDeepLinkBus.emit(
      AppDeepLinkCommand(
        tabIndex: cmd.tabIndex ?? 3,
        message: cmd.message,
        success: cmd.success,
        kind: cmd.kind,
        entityId: cmd.entityId,
      ),
    );
  }
}
