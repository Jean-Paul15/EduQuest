import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationPreferences {
  const NotificationPreferences({
    required this.revisionEnabled,
    required this.contestEnabled,
    required this.eventEnabled,
    required this.reminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
  });

  final bool revisionEnabled;
  final bool contestEnabled;
  final bool eventEnabled;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
}

class NotificationPreferencesRepository {
  final _local = LocalJsonCache();

  Future<NotificationPreferences> get() async {
    final local = await _fromLocal();
    if (!Env.hasSupabase) return local ?? _defaultPrefs();
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return local ?? _defaultPrefs();
    try {
      final row = await Supabase.instance.client
          .from('notification_preferences')
          .select(
            'revision_enabled,contest_enabled,event_enabled,reminder_enabled,reminder_hour,reminder_minute',
          )
          .eq('profile_id', uid)
          .maybeSingle();
      if (row == null) return local ?? _defaultPrefs();
      final out = NotificationPreferences(
        revisionEnabled: row['revision_enabled'] as bool? ?? true,
        contestEnabled: row['contest_enabled'] as bool? ?? true,
        eventEnabled: row['event_enabled'] as bool? ?? true,
        reminderEnabled: row['reminder_enabled'] as bool? ?? false,
        reminderHour: row['reminder_hour'] as int? ?? 19,
        reminderMinute: row['reminder_minute'] as int? ?? 0,
      );
      await _writeLocal(out);
      return out;
    } catch (_) {
      return local ?? _defaultPrefs();
    }
  }

  Future<void> save(NotificationPreferences p) async {
    await _writeLocal(p);
    if (!Env.hasSupabase) return;
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await Supabase.instance.client.from('notification_preferences').upsert({
        'profile_id': uid,
        'revision_enabled': p.revisionEnabled,
        'contest_enabled': p.contestEnabled,
        'event_enabled': p.eventEnabled,
        'reminder_enabled': p.reminderEnabled,
        'reminder_hour': p.reminderHour,
        'reminder_minute': p.reminderMinute,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {}
  }

  NotificationPreferences _defaultPrefs() => const NotificationPreferences(
    revisionEnabled: true,
    contestEnabled: true,
    eventEnabled: true,
    reminderEnabled: false,
    reminderHour: 19,
    reminderMinute: 0,
  );

  Future<NotificationPreferences?> _fromLocal() async {
    final rows = await _local.readList('notif:prefs');
    if (rows == null || rows.isEmpty) return null;
    final r = rows.first;
    return NotificationPreferences(
      revisionEnabled: r['revisionEnabled'] as bool? ?? true,
      contestEnabled: r['contestEnabled'] as bool? ?? true,
      eventEnabled: r['eventEnabled'] as bool? ?? true,
      reminderEnabled: r['reminderEnabled'] as bool? ?? false,
      reminderHour: r['reminderHour'] as int? ?? 19,
      reminderMinute: r['reminderMinute'] as int? ?? 0,
    );
  }

  Future<void> _writeLocal(NotificationPreferences p) async {
    await _local.writeList('notif:prefs', [
      {
        'revisionEnabled': p.revisionEnabled,
        'contestEnabled': p.contestEnabled,
        'eventEnabled': p.eventEnabled,
        'reminderEnabled': p.reminderEnabled,
        'reminderHour': p.reminderHour,
        'reminderMinute': p.reminderMinute,
      },
    ]);
  }
}
