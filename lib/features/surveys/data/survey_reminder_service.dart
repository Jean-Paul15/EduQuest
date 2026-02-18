import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/notifications/data/local_reminder_service.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SurveyReminderService {
  static const _lastKey = 'survey_pending_reminder_ms';
  static const _notifId = 9404;
  final _engagement = EngagementRepository();
  final _local = LocalReminderService();

  Future<void> remindIfNeeded({
    Duration cooldown = const Duration(hours: 36),
  }) async {
    if (!Env.hasSupabase) return;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = prefs.getInt(_lastKey) ?? 0;
    if (last > 0 && now - last < cooldown.inMilliseconds) return;
    final pending = await _engagement.listSurveys();
    if (pending.isEmpty) return;
    await _local.initialize();
    await _local.showInfo(
      id: _notifId,
      title: 'Enquête EduQuest',
      body: 'Réponds à l’enquête de la semaine pour améliorer l’app.',
    );
    await prefs.setInt(_lastKey, now);
  }
}
