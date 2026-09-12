import 'dart:async';
import 'package:eduquest/features/notifications/data/local_reminder_service.dart';
import 'package:eduquest/features/notifications/data/notification_preferences_repository.dart';
import 'package:eduquest/features/notifications/data/push_subscription_repository.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/deeplink/app_deep_link_command.dart';
import 'package:eduquest/shared/deeplink/app_deep_link_parser.dart';
import 'package:eduquest/shared/navigation/app_navigator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const _integrationDialogSeenKey = 'onesignal.integration_dialog_seen';
  static bool _initialized = false;
  static bool _handlersBound = false;
  static bool _integrationDialogShown = false;
  static bool _integrationDialogStateLoaded = false;
  static bool _integrationDialogPending = false;
  static bool _integrationDialogRetryQueued = false;
  static bool _userContextReady = false;
  final _local = LocalReminderService();
  final _pushRepo = PushSubscriptionRepository();
  final _analytics = AppAnalytics();
  bool get _supportsPush => Env.hasOneSignal && !kIsWeb;

  Future<void> initialize() async {
    if (_initialized) return;
    await _local.initialize();
    await _loadIntegrationDialogState();
    if (_supportsPush) {
      setLogLevel(OSLogLevel.none);
      OneSignal.initialize(Env.oneSignalAppId);
      _bindHandlers();
    }
    _initialized = true;
  }

  void notifyUiReady() {
    _flushIntegrationDialog();
  }

  void setLogLevel(OSLogLevel level) {
    if (!_supportsPush) return;
    OneSignal.Debug.setLogLevel(level);
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
    if (!_supportsPush) return;
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
    _userContextReady = true;
    _queueIntegrationDialog(OneSignal.User.pushSubscription.id);
    await _syncPushState(permissionGranted: OneSignal.Notifications.permission);
  }

  Future<void> setExternalUserId(String userId) async {
    await initialize();
    if (!_supportsPush) return;
    await OneSignal.login(userId);
  }

  Future<void> clearExternalUserId() async {
    await initialize();
    if (!_supportsPush) return;
    _userContextReady = false;
    await OneSignal.logout();
  }

  Future<void> addEmail(String email) async {
    await initialize();
    if (!_supportsPush) return;
    await OneSignal.User.addEmail(email);
  }

  Future<void> removeEmail(String email) async {
    await initialize();
    if (!_supportsPush) return;
    await OneSignal.User.removeEmail(email);
  }

  Future<void> addSms(String phoneNumber) async {
    await initialize();
    if (!_supportsPush) return;
    await OneSignal.User.addSms(phoneNumber);
  }

  Future<void> removeSms(String phoneNumber) async {
    await initialize();
    if (!_supportsPush) return;
    await OneSignal.User.removeSms(phoneNumber);
  }

  Future<void> setLearningTags({
    required String country,
    required String level,
    required String serie,
  }) async {
    await initialize();
    if (!_supportsPush) return;
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
    await initialize();
    if (!_supportsPush) return;
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

  void _bindHandlers() {
    if (_handlersBound || !_supportsPush) return;
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
      _queueIntegrationDialog(state.current.id);
    });
    OneSignal.Notifications.addClickListener((event) {
      final title = event.notification.title ?? 'Notification RuachEdu';
      final body = event.notification.body ?? '';
      final payload = _payload(event.notification.additionalData ?? {});
      payload['deeplink'] =
          payload['deeplink'] ??
          event.result.url ??
          event.notification.launchUrl ??
          '';
      _dispatchPayload(payload, body.isEmpty ? title : '$title • $body');
      unawaited(_analytics.track('push_clicked', payload: payload));
    });
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      final title = event.notification.title ?? 'Notification RuachEdu';
      final body = event.notification.body ?? '';
      final payload = _payload(event.notification.additionalData ?? {});
      _dispatchPayload(payload, body.isEmpty ? title : '$title • $body');
      unawaited(_analytics.track('push_received', payload: payload));
    });
    _queueIntegrationDialog(OneSignal.User.pushSubscription.id);
    _handlersBound = true;
  }

  Future<void> _syncPushState({
    required bool permissionGranted,
    String? subscriptionId,
    String? token,
    bool? optedIn,
  }) async {
    final sid = subscriptionId ?? OneSignal.User.pushSubscription.id ?? '';
    if (!_isRegisteredSubscription(sid)) return;
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
        params: cmd.params,
      ),
    );
  }

  Future<void> _loadIntegrationDialogState() async {
    if (_integrationDialogStateLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    _integrationDialogShown = prefs.getBool(_integrationDialogSeenKey) ?? false;
    _integrationDialogStateLoaded = true;
  }

  bool _isRegisteredSubscription(String? id) =>
      id != null && id.isNotEmpty && !id.startsWith('local-');

  void _queueIntegrationDialog(String? subscriptionId) {
    // Ne dépend PAS d'un abonnement OneSignal déjà "enregistré" -- lire
    // `pushSubscription.id` juste après l'initialisation est connu pour
    // rester null/local de façon non fiable côté SDK, ce qui créait une
    // dépendance circulaire (le dialogue de demande de permission
    // n'apparaissait jamais tant qu'un abonnement n'existait pas déjà).
    // La seule condition réellement nécessaire est la permission OS.
    if (!_userContextReady ||
        OneSignal.Notifications.permission ||
        _integrationDialogShown) {
      return;
    }
    _integrationDialogPending = true;
    _flushIntegrationDialog();
  }

  void _flushIntegrationDialog() {
    if (!_integrationDialogPending || _integrationDialogShown) return;
    final navigator = appNavigatorKey.currentState;
    final context = navigator?.context;
    if (navigator == null || context == null || !navigator.mounted) {
      if (_integrationDialogRetryQueued) return;
      _integrationDialogRetryQueued = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _integrationDialogRetryQueued = false;
        _flushIntegrationDialog();
      });
      return;
    }
    _integrationDialogPending = false;
    _integrationDialogShown = true;
    unawaited(_persistIntegrationDialogSeen());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        showCupertinoDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: const Text('Reste informé avec RuachEdu'),
            content: const Text(
              'Active les notifications pour recevoir les rappels utiles, les lives, les concours et les nouvelles ressources au bon moment.',
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(dialogContext, rootNavigator: true).pop();
                },
                child: const Text('Plus tard'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(dialogContext, rootNavigator: true).pop();
                  unawaited(OneSignal.Notifications.requestPermission(true));
                },
                child: const Text('Autoriser'),
              ),
            ],
          ),
        );
        return;
      }
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Reste informé avec RuachEdu'),
          content: const Text(
            'Active les notifications pour recevoir les rappels utiles, les lives, les concours et les nouvelles ressources au bon moment.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext, rootNavigator: true).pop();
              },
              child: const Text('Plus tard'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext, rootNavigator: true).pop();
                unawaited(OneSignal.Notifications.requestPermission(true));
              },
              child: const Text('Autoriser'),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _persistIntegrationDialogSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_integrationDialogSeenKey, true);
  }
}
