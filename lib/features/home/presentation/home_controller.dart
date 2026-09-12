import 'dart:async';
import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/shared/sync/service_locator.dart';
import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/gamification/data/gamification_repository.dart';
import 'package:eduquest/features/gamification/domain/gamification_state.dart';
import 'package:eduquest/features/home/data/home_snapshot_cache.dart';
import 'package:eduquest/features/home/domain/home_snapshot.dart';
import 'package:eduquest/features/home/presentation/home_realtime.dart';
import 'package:eduquest/features/notifications/data/notification_preferences_repository.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/features/user/domain/user_profile.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';

class HomeController {
  final _auth = AuthRepository();
  final _accessRepo = ServiceLocator().accessRepo;
  final _notif = NotificationService();
  StreamSubscription<AccessState>? _accessSub;
  AccessState _lastAccess = const AccessState(
    tier: 'FREE_LIGHT',
    hasAccess: true,
    expiresAt: null,
  );
  final _prefsRepo = NotificationPreferencesRepository();
  final _analytics = AppAnalytics();
  final _gamificationRepo = GamificationRepository();
  final _profileRepo = UserProfileRepository();
  final _cache = HomeSnapshotCache();
  late final HomeRealtime _realtime = HomeRealtime(_auth);

  Future<HomeSnapshot?> loadCachedSnapshot() => _cache.read();

  Future<HomeSnapshot> initialize() async {
    _accessSub ??= _accessRepo.accessStream.listen((s) => _lastAccess = s);
    final cached = await _cache.read();
    if (_auth.currentUser == null && cached != null) return cached;
    final profile = await _profileRepo.load();
    unawaited(_warmNotifications(profile));
    unawaited(_analytics.track('home_opened', category: 'navigation'));
    return refresh();
  }

  Future<HomeSnapshot> refresh() async {
    final cached = await _cache.read();
    if (_auth.currentUser == null && cached != null) return cached;
    try {
      final accessF = _accessRepo.resolveAccess();
      final profileF = _profileRepo.load();
      final gamificationF = _gamificationRepo.loadState();
      final questsF = _gamificationRepo.listDailyQuests();
      final access = (await accessF).dataOrNull ?? _lastAccess;
      final rawGam = await gamificationF;
      final rawQuests = await questsF;
      final snapshot = HomeSnapshot(
        displayName: (await profileF).displayName,
        access: access,
        gamification:
            rawGam.dataOrNull ??
            const GamificationState(
              xp: 0,
              level: 1,
              streakDays: 0,
              bestStreak: 0,
            ),
        quests: rawQuests.dataOrNull ?? const [],
      );
      unawaited(_cache.write(snapshot));
      return snapshot;
    } catch (_) {
      if (cached != null) return cached;
      final p = await _profileRepo.load();
      return HomeSnapshot(
        displayName: p.displayName,
        access: const AccessState(
          tier: 'FREE_LIGHT',
          hasAccess: true,
          expiresAt: null,
        ),
        gamification:
            (await _gamificationRepo.loadState()).dataOrNull ??
            const GamificationState(
              xp: 0,
              level: 1,
              streakDays: 0,
              bestStreak: 0,
            ),
        quests:
            (await _gamificationRepo.listDailyQuests()).dataOrNull ?? const [],
      );
    }
  }

  Future<String> claimCheckin() async {
    final r = await _gamificationRepo.claimDailyCheckin();
    return r.dataOrNull ?? 'Erreur inconnue.';
  }

  Future<void> track(String event) => _analytics.track(event);

  Future<void> _warmNotifications(UserProfile profile) async {
    try {
      final uid = _auth.currentUser?.id;
      if (uid == null) return;
      final prefs = await _prefsRepo.get();
      final access = _lastAccess;
      await _notif.syncUserContext(
        userId: uid,
        country: profile.countryCode,
        level: profile.levelCode,
        serie: profile.serieCode,
        ticketTier: access.tier,
        prefs: prefs,
      );
      await _notif.syncDailyReminder(
        prefs: prefs,
        displayName: profile.displayName,
      );
    } catch (_) {}
  }

  void dispose() {
    _accessSub?.cancel();
    stopRealtime();
  }

  void startRealtime(void Function() onChange) => _realtime.subscribe(onChange);
  void stopRealtime() => _realtime.unsubscribe();
}
