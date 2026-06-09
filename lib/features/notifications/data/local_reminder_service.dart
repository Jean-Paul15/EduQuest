import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalReminderService {
  static const _id = 9401;
  static const _previewId = 9402;
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(init);
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'eduquest_alerts',
        'RuachEdu Alerts',
        description: 'Notifications importantes RuachEdu',
        importance: Importance.max,
        playSound: true,
      ),
    );
    await android?.requestNotificationsPermission();
    try {
      await (android as dynamic).requestExactAlarmsPermission();
    } catch (_) {}
    tz.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {}
  }

  Future<void> scheduleDaily({
    required bool enabled,
    required int hour,
    required int minute,
    required String displayName,
  }) async {
    if (!enabled) return cancelDaily();
    await _plugin.cancel(_id);
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'revision_daily',
        'Rappels révision',
        channelDescription: 'Rappels quotidiens RuachEdu',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    try {
      await _plugin.zonedSchedule(
        _id,
        'EduQuest • Rappel de révision',
        '$displayName, il est temps de réviser un chapitre.',
        next,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        _id,
        'EduQuest • Rappel de révision',
        '$displayName, il est temps de réviser un chapitre.',
        next,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelDaily() async => _plugin.cancel(_id);

  Future<void> showPreview(String displayName) async {
    await _plugin.show(
      _previewId,
      'EduQuest • Test rappel',
      '$displayName, les rappels sont bien actifs.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'revision_daily',
          'Rappels révision',
          channelDescription: 'Rappels quotidiens RuachEdu',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showInfo({
    required String title,
    required String body,
    int id = 9403,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'revision_daily',
          'Rappels révision',
          channelDescription: 'Rappels quotidiens RuachEdu',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
