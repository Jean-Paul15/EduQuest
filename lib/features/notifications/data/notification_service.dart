import 'package:eduquest/features/notifications/data/local_reminder_service.dart';
import 'package:eduquest/features/notifications/data/notification_preferences_repository.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  static bool _initialized = false;
  final _local = LocalReminderService();

  Future<void> initialize() async {
    if (_initialized) return;
    await _local.initialize();
    if (Env.hasOneSignal) {
      OneSignal.Debug.setLogLevel(OSLogLevel.none);
      OneSignal.initialize(Env.oneSignalAppId);
      await OneSignal.Notifications.requestPermission(true);
    }
    _initialized = true;
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
}
