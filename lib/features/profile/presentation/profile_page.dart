import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/class_selection/presentation/class_selection_panel.dart';
import 'package:eduquest/features/legal/presentation/legal_document_page.dart';
import 'package:eduquest/features/notifications/data/notification_preferences_repository.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/features/profile/presentation/widgets/profile_actions.dart';
import 'package:eduquest/features/profile/presentation/widgets/reminder_setting_tile.dart';
import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/features/widget/data/home_widget_service.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.onThemeToggle,
    required this.themeMode,
  });
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = AuthRepository(),
      _prefsRepo = NotificationPreferencesRepository(),
      _notif = NotificationService(),
      _widget = HomeWidgetService(),
      _user = UserProfileRepository();
  String _name = 'Etudiant',
      _countryCode = 'TG',
      _levelCode = 'Terminale',
      _serieCode = 'D';
  NotificationPreferences _prefs = const NotificationPreferences(
    revisionEnabled: true,
    contestEnabled: true,
    eventEnabled: true,
    reminderEnabled: false,
    reminderHour: 19,
    reminderMinute: 0,
  );

  @override
  void initState() {
    super.initState();
    _prefsRepo.get().then((v) => mounted ? setState(() => _prefs = v) : null);
    _reloadProfile();
  }

  Future<void> _reloadProfile() async {
    final u = await _user.load();
    if (!mounted) return;
    setState(() {
      _name = u.displayName;
      _countryCode = u.countryCode;
      _levelCode = u.levelCode;
      _serieCode = u.serieCode;
    });
  }

  String _initials(String s) {
    final p = s
        .split(RegExp(r'\s+'))
        .where((e) => e.trim().isNotEmpty)
        .toList(growable: false);
    if (p.isEmpty) return 'E';
    if (p.length == 1) return p.first[0].toUpperCase();
    return '${p.first[0]}${p.last[0]}'.toUpperCase();
  }

  NotificationPreferences _w({bool? r, bool? c, bool? e, bool? m}) =>
      NotificationPreferences(
        revisionEnabled: r ?? _prefs.revisionEnabled,
        contestEnabled: c ?? _prefs.contestEnabled,
        eventEnabled: e ?? _prefs.eventEnabled,
        reminderEnabled: m ?? _prefs.reminderEnabled,
        reminderHour: _prefs.reminderHour,
        reminderMinute: _prefs.reminderMinute,
      );

  Future<void> _save(NotificationPreferences p) async {
    final wasReminderEnabled = _prefs.reminderEnabled;
    setState(() => _prefs = p);
    await _prefsRepo.save(p);
    await _notif.setTopicTags(
      revisionEnabled: p.revisionEnabled,
      contestEnabled: p.contestEnabled,
      eventEnabled: p.eventEnabled,
    );
    await _notif.syncDailyReminder(prefs: p, displayName: _name);
    if (!wasReminderEnabled && p.reminderEnabled) {
      await _notif.sendReminderPreview(_name);
    }
    if (!mounted) return;
    final hh = p.reminderHour.toString().padLeft(2, '0');
    final mm = p.reminderMinute.toString().padLeft(2, '0');
    ModernSnackbar.show(
      context,
      p.reminderEnabled ? 'Rappel actif a $hh:$mm.' : 'Rappel desactive.',
    );
  }

  Future<void> _pickReminderTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _prefs.reminderHour,
        minute: _prefs.reminderMinute,
      ),
    );
    if (t == null) return;
    await _save(
      NotificationPreferences(
        revisionEnabled: _prefs.revisionEnabled,
        contestEnabled: _prefs.contestEnabled,
        eventEnabled: _prefs.eventEnabled,
        reminderEnabled: _prefs.reminderEnabled,
        reminderHour: t.hour,
        reminderMinute: t.minute,
      ),
    );
    if (mounted) {
      ModernSnackbar.show(context, 'Rappel regle a ${t.format(context)}');
    }
  }

  Future<void> _pinWidget() async {
    if (!await _widget.canPin()) {
      return mounted
          ? ModernSnackbar.show(
              context,
              'Non supporte par ce lanceur.',
              success: false,
            )
          : null;
    }
    await _widget.requestPin();
    if (mounted) ModernSnackbar.show(context, "Widget propose sur l'accueil.");
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(cs),
          const SizedBox(height: 16),
          _settings(),
          const SizedBox(height: 16),
          ClassSelectionPanel(onChanged: _reloadProfile),
          const SizedBox(height: 12),
          ProfileActions(
            onWidgetUpdate: () => _widget.update(
              title: 'EduQuest \u2022 $_name',
              focusLabel: 'Rappel',
              focusValue: 'Revision du jour',
            ),
            onWidgetPin: _pinWidget,
            onOpenTerms: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LegalDocumentPage(docType: 'terms'),
              ),
            ),
            onOpenPrivacy: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LegalDocumentPage(docType: 'privacy'),
              ),
            ),
            onSignOut: _auth.signOut,
          ),
        ],
      ),
    );
  }

  Widget _header(ColorScheme cs) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(color: AppColors.divider),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: cs.primary,
          child: Text(
            _initials(_name),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$_levelCode \u2022 Serie $_serieCode \u2022 $_countryCode',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _settings() => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(color: AppColors.divider),
    ),
    child: Column(
      children: [
        SwitchListTile(
          value: widget.themeMode == ThemeMode.dark,
          onChanged: (_) => widget.onThemeToggle(),
          title: const Text('Theme sombre'),
          dense: true,
        ),
        const Divider(height: 1, color: AppColors.divider),
        SwitchListTile(
          value: _prefs.revisionEnabled,
          onChanged: (v) => _save(_w(r: v)),
          title: const Text('Notifications revision'),
          dense: true,
        ),
        SwitchListTile(
          value: _prefs.contestEnabled,
          onChanged: (v) => _save(_w(c: v)),
          title: const Text('Notifications concours'),
          dense: true,
        ),
        SwitchListTile(
          value: _prefs.eventEnabled,
          onChanged: (v) => _save(_w(e: v)),
          title: const Text('Notifications evenements'),
          dense: true,
        ),
        const Divider(height: 1, color: AppColors.divider),
        ReminderSettingTile(
          enabled: _prefs.reminderEnabled,
          hour: _prefs.reminderHour,
          minute: _prefs.reminderMinute,
          onToggle: (v) => _save(_w(m: v)),
          onPickTime: _pickReminderTime,
        ),
      ],
    ),
  );
}
