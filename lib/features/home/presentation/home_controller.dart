import 'dart:async';
import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/gamification/data/gamification_repository.dart';
import 'package:eduquest/features/home/data/home_snapshot_cache.dart';
import 'package:eduquest/features/home/domain/home_snapshot.dart';
import 'package:eduquest/features/notifications/data/notification_preferences_repository.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/features/user/domain/user_profile.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController {
  final _auth = AuthRepository();
  final _accessRepo = AccessRepository();
  final _notif = NotificationService();
  final _prefsRepo = NotificationPreferencesRepository();
  final _analytics = AppAnalytics();
  final _gamificationRepo = GamificationRepository();
  final _profileRepo = UserProfileRepository();
  final _cache = HomeSnapshotCache();
  RealtimeChannel? _channel;

  Future<HomeSnapshot?> loadCachedSnapshot() => _cache.read();

  Future<HomeSnapshot> initialize() async {
    final cached = await _cache.read();
    if (_auth.currentUser == null && cached != null) return cached;
    final profile = await _profileRepo.load();
    unawaited(_warmNotifications(profile));
    unawaited(_analytics.track('home_opened'));
    return refresh();
  }

  Future<HomeSnapshot> refresh() async {
    final cached = await _cache.read();
    if (_auth.currentUser == null && cached != null) return cached;
    try {
      final profileF = _profileRepo.load();
      final accessF = _accessRepo.resolveAccess();
      final gamificationF = _gamificationRepo.loadState();
      final questsF = _gamificationRepo.listDailyQuests();
      final snapshot = HomeSnapshot(
        displayName: (await profileF).displayName,
        access: await accessF,
        gamification: await gamificationF,
        quests: await questsF,
      );
      unawaited(_cache.write(snapshot));
      return snapshot;
    } catch (_) {
      if (cached != null) return cached;
      final p = await _profileRepo.load();
      return HomeSnapshot(
        displayName: p.displayName,
        access: const AccessState(
          tier: 'FREE',
          hasAccess: true,
          expiresAt: null,
        ),
        gamification: await _gamificationRepo.loadState(),
        quests: await _gamificationRepo.listDailyQuests(),
      );
    }
  }

  Future<String> claimCheckin() => _gamificationRepo.claimDailyCheckin();
  Future<void> track(String event) => _analytics.track(event);

  Future<void> _warmNotifications(UserProfile profile) async {
    try {
      final uid = _auth.currentUser?.id;
      if (uid != null) await _notif.setExternalUserId(uid);
      await _notif.setLearningTags(
        country: profile.countryCode,
        level: profile.levelCode,
        serie: profile.serieCode,
      );
      await _notif.syncDailyReminder(
        prefs: await _prefsRepo.get(),
        displayName: profile.displayName,
      );
    } catch (_) {}
  }

  void startRealtime(void Function() onChange) {
    if (!Env.hasSupabase) return;
    final uid = _auth.currentUser?.id;
    if (uid == null) return;
    final c = Supabase.instance.client;
    _channel = c
        .channel('home-$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'gamification_profiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'profile_id',
            value: uid,
          ),
          callback: (_) => onChange(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'ticket_codes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'activated_by',
            value: uid,
          ),
          callback: (_) => onChange(),
        )
        .subscribe();
  }

  void stopRealtime() {
    final ch = _channel;
    if (ch == null) return;
    Supabase.instance.client.removeChannel(ch);
    _channel = null;
  }
}
