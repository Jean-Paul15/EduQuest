import 'dart:async';
import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/shared/config/feature_flag_service.dart';
import 'package:eduquest/shared/media/media_cache_service.dart';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/data/live_classes_repository.dart';
import 'package:eduquest/features/learning/data/chapter_content_repository.dart';
import 'package:eduquest/features/learning/data/exam_repository.dart';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/learning/data/learning_content_repository.dart';
import 'package:eduquest/features/marketplace/data/marketplace_repository.dart';
import 'package:eduquest/features/videos/data/video_repository.dart';
import 'package:eduquest/shared/network/connectivity_oracle.dart';
import 'package:eduquest/shared/realtime/cache_invalidation_bus.dart';
import 'package:eduquest/shared/realtime/content_realtime_service.dart';
import 'package:eduquest/shared/security/content_security_service.dart';
import 'package:eduquest/shared/sync/background_sync_service.dart';
import 'package:eduquest/shared/sync/offline_state_notifier.dart';
import 'package:eduquest/shared/sync/sync_queue.dart';
import 'package:eduquest/shared/sync/sync_service.dart';
import 'package:get_it/get_it.dart';

// Re-export key services so consumers don't need separate imports.
export 'package:eduquest/shared/config/feature_flag_service.dart';
export 'package:eduquest/shared/network/connectivity_oracle.dart';
export 'package:eduquest/shared/sync/offline_state_notifier.dart';
export 'package:eduquest/shared/sync/sync_queue.dart';
export 'package:eduquest/shared/sync/sync_service.dart';

/// Lightweight service locator backed by GetIt (§11.4).
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._();
  factory ServiceLocator() => _instance;
  ServiceLocator._() { _register(); }
  final _g = GetIt.instance;
  bool _started = false;

  void _register() {
    _g.registerLazySingleton<ConnectivityOracle>(() => ConnectivityOracle());
    _g.registerLazySingleton<SyncQueue>(() => SyncQueue());
    _g.registerLazySingleton<SyncService>(() => SyncService(queue: queue, oracle: oracle));
    _g.registerLazySingleton<OfflineStateNotifier>(() => OfflineStateNotifier(oracle: oracle, queue: queue));
    _g.registerLazySingleton<FeatureFlagService>(() => FeatureFlagService());
    _g.registerLazySingleton<MediaCacheService>(() => MediaCacheService());
    _g.registerLazySingleton<ContentSecurityService>(() => ContentSecurityService());
    _g.registerLazySingleton<AccessRepository>(() => AccessRepository());
  }

  ConnectivityOracle get oracle => _g<ConnectivityOracle>();
  SyncQueue get queue => _g<SyncQueue>();
  SyncService get sync => _g<SyncService>();
  OfflineStateNotifier get notifier => _g<OfflineStateNotifier>();
  FeatureFlagService get featureFlags => _g<FeatureFlagService>();
  MediaCacheService get mediaCache => _g<MediaCacheService>();
  ContentSecurityService get contentSecurity => _g<ContentSecurityService>();
  AccessRepository get accessRepo => _g<AccessRepository>();

  void start() {
    if (_started) return;
    unawaited(featureFlags.loadFlags());
    sync.start();
    _g<ContentSecurityService>(); // force lazy creation
    unawaited(BackgroundSyncService.initialize());
    unawaited(accessRepo.resolveAccess()); // warm access stream
    _registerContentEvictors();
    unawaited(ContentRealtimeService.instance.start());
    oracle.addListener(_onConnectivity);
    _started = true;
  }

  void stop() {
    sync.stop();
    unawaited(BackgroundSyncService.cancelAll());
    accessRepo.dispose();
    oracle.removeListener(_onConnectivity);
    unawaited(ContentRealtimeService.instance.stop());
    _started = false;
  }

  bool _evictorsRegistered = false;
  void _registerContentEvictors() {
    if (_evictorsRegistered) return;
    _evictorsRegistered = true;
    final bus = CacheInvalidationBus.instance;
    bus.registerMemEvictor(ChapterContentRepository.evictKeys);
    bus.registerMemEvictor(LearningCatalogRepository.evictKeys);
    bus.registerMemEvictor(LearningContentRepository.evictKeys);
    bus.registerMemEvictor(ExamRepository.evictKeys);
    bus.registerMemEvictor(VideoRepository.evictKeys);
    bus.registerMemEvictor(EngagementRepository.evictKeys);
    bus.registerMemEvictor(LiveClassesRepository.evictKeys);
    bus.registerMemEvictor(MarketplaceRepository.evictKeys);
  }

  bool _wasOnline = true;
  void _onConnectivity() {
    final online = oracle.isOnline;
    if (online && !_wasOnline) {
      unawaited(ContentRealtimeService.instance.resync()); // retour du reseau
    }
    _wasOnline = online;
  }

  /// Dispose and re-register all services. Useful for testing.
  void reset() {
    stop();
    if (_g.isRegistered<OfflineStateNotifier>()) _g<OfflineStateNotifier>().dispose();
    if (_g.isRegistered<ConnectivityOracle>()) _g<ConnectivityOracle>().dispose();
    _g.reset();
    _register();
  }
}
