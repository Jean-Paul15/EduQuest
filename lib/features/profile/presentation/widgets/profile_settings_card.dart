import 'package:eduquest/features/notifications/data/notification_preferences_repository.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/features/profile/presentation/widgets/reminder_setting_tile.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:flutter/material.dart';

class ProfileSettingsCard extends StatefulWidget {
  const ProfileSettingsCard({
    super.key,
    required this.themeMode,
    required this.onThemeToggle,
    required this.displayName,
  });
  final ThemeMode themeMode;
  final VoidCallback onThemeToggle;
  final String displayName;
  @override
  State<ProfileSettingsCard> createState() => _ProfileSettingsCardState();
}

class _ProfileSettingsCardState extends State<ProfileSettingsCard> {
  final _prefsRepo = NotificationPreferencesRepository();
  final _notif = NotificationService();
  NotificationPreferences _prefs = const NotificationPreferences(
    revisionEnabled: true, contestEnabled: true, eventEnabled: true,
    reminderEnabled: false, reminderHour: 19, reminderMinute: 0,
  );

  @override
  void initState() {
    super.initState();
    _prefsRepo.get().then((v) {
      if (!mounted) return;
      setState(() => _prefs = v);
      _notif.setTopicTags(revisionEnabled: v.revisionEnabled,
          contestEnabled: v.contestEnabled, eventEnabled: v.eventEnabled);
    });
  }

  NotificationPreferences _w({bool? r, bool? c, bool? e, bool? m}) => NotificationPreferences(
    revisionEnabled: r ?? _prefs.revisionEnabled, contestEnabled: c ?? _prefs.contestEnabled,
    eventEnabled: e ?? _prefs.eventEnabled, reminderEnabled: m ?? _prefs.reminderEnabled,
    reminderHour: _prefs.reminderHour, reminderMinute: _prefs.reminderMinute,
  );

  Future<void> _save(NotificationPreferences p) async {
    final was = _prefs.reminderEnabled;
    setState(() => _prefs = p);
    await _prefsRepo.save(p);
    await _notif.setTopicTags(revisionEnabled: p.revisionEnabled,
        contestEnabled: p.contestEnabled, eventEnabled: p.eventEnabled);
    await _notif.syncDailyReminder(prefs: p, displayName: widget.displayName);
    if (!was && p.reminderEnabled) await _notif.sendReminderPreview(widget.displayName);
    if (!mounted) return;
    final hh = p.reminderHour.toString().padLeft(2, '0');
    final mm = p.reminderMinute.toString().padLeft(2, '0');
    ModernSnackbar.show(context,
        p.reminderEnabled ? 'Rappel actif a $hh:$mm.' : 'Rappel desactive.');
  }

  Future<void> _pickReminderTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _prefs.reminderHour, minute: _prefs.reminderMinute),
    );
    if (t == null) return;
    await _save(NotificationPreferences(
      revisionEnabled: _prefs.revisionEnabled, contestEnabled: _prefs.contestEnabled,
      eventEnabled: _prefs.eventEnabled, reminderEnabled: _prefs.reminderEnabled,
      reminderHour: t.hour, reminderMinute: t.minute,
    ));
    if (mounted) ModernSnackbar.show(context, 'Rappel regle a ${t.format(context)}');
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(RuachRadius.lg),
      border: Border.all(color: RuachColors.cream200),
    ),
    child: Column(children: [
      SwitchListTile(value: widget.themeMode == ThemeMode.dark,
          onChanged: (_) => widget.onThemeToggle(), title: const Text('Thème sombre'), dense: true),
      const Divider(height: 1, color: RuachColors.cream200),
      SwitchListTile(value: _prefs.revisionEnabled, onChanged: (v) => _save(_w(r: v)),
          title: const Text('Notifications révision'), dense: true),
      SwitchListTile(value: _prefs.contestEnabled, onChanged: (v) => _save(_w(c: v)),
          title: const Text('Notifications concours'), dense: true),
      SwitchListTile(value: _prefs.eventEnabled, onChanged: (v) => _save(_w(e: v)),
          title: const Text('Notifications événements'), dense: true),
      const Divider(height: 1, color: RuachColors.cream200),
      ReminderSettingTile(enabled: _prefs.reminderEnabled, hour: _prefs.reminderHour,
          minute: _prefs.reminderMinute, onToggle: (v) => _save(_w(m: v)), onPickTime: _pickReminderTime),
    ]),
  );
}
