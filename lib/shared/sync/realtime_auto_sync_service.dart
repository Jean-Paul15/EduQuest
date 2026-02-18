import 'dart:async';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/data/live_classes_repository.dart';
import 'package:eduquest/features/home/presentation/home_controller.dart';
import 'package:eduquest/features/learning/data/chapter_content_repository.dart';
import 'package:eduquest/features/learning/data/exam_repository.dart';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/learning/data/learning_warmup_service.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeAutoSyncService {
  RealtimeAutoSyncService({this.onSynced});
  final VoidCallback? onSynced;
  final _home = HomeController();
  final _learning = LearningWarmupService();
  final _engagement = EngagementRepository();
  final _lives = LiveClassesRepository();
  final _local = LocalJsonCache();
  RealtimeChannel? _channel;
  Timer? _debounce;
  bool _busy = false;

  Future<void> start() async {
    if (!Env.hasSupabase || _channel != null) return;
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final tables = [
      'resources',
      'quizzes',
      'quiz_questions',
      'exam_papers',
      'chapters',
      'contests',
      'events',
      'surveys',
      'live_classes',
      'user_notifications',
      'notification_campaigns',
      'marketplace_items',
      'app_config',
    ];
    final c = Supabase.instance.client;
    final ch = c.channel('auto-sync-$uid');
    for (final t in tables) {
      ch.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: t,
        callback: (_) => _schedule(),
      );
    }
    ch.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'profiles',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: uid,
      ),
      callback: (_) => _schedule(),
    );
    _channel = ch.subscribe();
  }

  void stop() {
    _debounce?.cancel();
    final ch = _channel;
    if (ch != null) Supabase.instance.client.removeChannel(ch);
    _channel = null;
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), _syncNow);
  }

  Future<void> _syncNow() async {
    if (_busy) return;
    _busy = true;
    try {
      await _local.removeByPrefixes([
        'feed:',
        'hub:',
        'learn:',
        'exam:',
        'chapter:',
        'leaderboard:',
        'market:',
        'orientation:',
        'user:profile',
      ]);
      LearningCatalogRepository.clearMemory();
      ExamRepository.clearMemory();
      ChapterContentRepository.clearMemory();
      EngagementRepository.clearMemory();
      LiveClassesRepository.clearMemory();
      await _home.refresh();
      await Future.wait(LearningSection.values.map(_learning.warmSection));
      await _lives.list();
      await _engagement.listContests();
      await _engagement.listEvents();
      await _engagement.listSurveys();
    } catch (_) {}
    onSynced?.call();
    _busy = false;
  }
}
