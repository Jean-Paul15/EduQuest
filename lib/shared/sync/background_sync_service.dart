import 'package:eduquest/shared/core/app_constants.dart';
import 'package:eduquest/shared/media/cache_cleanup_service.dart';
import 'package:eduquest/shared/network/connectivity_oracle.dart';
import 'package:eduquest/shared/sync/sync_queue.dart';
import 'package:eduquest/shared/sync/sync_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:workmanager/workmanager.dart';

const _syncTask = 'eduquest_background_sync';
const _cleanupTask = 'eduquest_cache_cleanup';

@pragma('vm:entry-point')
void _syncDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Cet isolate ne passe pas par `main()` : `dotenv` n'y est pas chargé, donc
    // `Env.*` renverrait '' et la synchro sonderait Google au lieu de Supabase.
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await dotenv.load(fileName: '.env');
    } catch (_) {}
    if (task == _syncTask) await _runBackgroundSync();
    if (task == _cleanupTask) await _runCacheCleanup();
    return true;
  });
}

Future<void> _runBackgroundSync() async {
  try {
    final oracle = ConnectivityOracle();
    if (!await oracle.waitUntilUsable()) {
      debugPrint('BackgroundSync: offline, skipping.');
      oracle.dispose();
      return;
    }
    final queue = SyncQueue();
    final pending = await queue.pendingCount();
    if (pending == 0) {
      debugPrint('BackgroundSync: no pending items.');
      return;
    }
    final svc = SyncService(queue: queue, oracle: oracle);
    svc.start();
    await Future<void>.delayed(const Duration(seconds: 30));
    svc.stop();
    oracle.dispose();
    debugPrint('BackgroundSync: done. ${await queue.pendingCount()} remain.');
  } catch (e) {
    debugPrint('BackgroundSync: error — $e');
  }
}

Future<void> _runCacheCleanup() async {
  try {
    final result = await const CacheCleanupService().runCleanup();
    result.fold(
      onSuccess: (s) => debugPrint(
        'CacheCleanup bg: -${s.filesRemoved} files, '
        '${(s.bytesFreed / 1048576).toStringAsFixed(1)} MB freed',
      ),
      onFailure: (e) => debugPrint('CacheCleanup bg: ${e.message}'),
    );
  } catch (e) {
    debugPrint('CacheCleanup bg: unhandled error — $e');
  }
}

class BackgroundSyncService {
  BackgroundSyncService._();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await Workmanager().initialize(_syncDispatcher);
      await Workmanager().registerPeriodicTask(
        _syncTask,
        _syncTask,
        frequency: Duration(
          minutes: OfflineConfig.backgroundSyncIntervalMinutes,
        ),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
      await Workmanager().registerPeriodicTask(
        _cleanupTask,
        _cleanupTask,
        frequency: const Duration(days: 7),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
      _initialized = true;
    } catch (e) {
      debugPrint('BackgroundSyncService: init failed — $e');
    }
  }

  static Future<void> cancelAll() async {
    try {
      await Workmanager().cancelAll();
      _initialized = false;
    } catch (e) {
      debugPrint('BackgroundSyncService: cancelAll failed — $e');
    }
  }
}
