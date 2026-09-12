import 'dart:async';
import 'package:eduquest/shared/core/app_constants.dart';
import 'package:eduquest/shared/network/connectivity_oracle.dart';
import 'package:eduquest/shared/sync/sync_queue.dart';
import 'package:flutter/foundation.dart';

/// Unified view of offline state for UI consumers.
///
/// Listens to [ConnectivityOracle] for real-time connection changes
/// and polls [SyncQueue] periodically for the pending item count.
/// This replaces scattered connectivity listeners and sync-queue
/// polling that were previously duplicated across UI widgets.
class OfflineStateNotifier extends ChangeNotifier {
  OfflineStateNotifier({
    required ConnectivityOracle oracle,
    required SyncQueue queue,
  }) : _oracle = oracle,
       _queue = queue {
    _isOffline = !_oracle.isOnline;
    _connectionState = _oracle.state;
    _syncCount();
    _oracle.addListener(_onConnectivityChanged);
    _pollTimer = Timer.periodic(
      Duration(seconds: OfflineConfig.pollSyncQueueSeconds),
      (_) => _syncCount(),
    );
  }

  final ConnectivityOracle _oracle;
  final SyncQueue _queue;
  Timer? _pollTimer;

  bool _isOffline = false;
  int _pendingCount = 0;
  ConnectionState _connectionState = ConnectionState.offline;

  bool get isOffline => _isOffline;
  int get pendingCount => _pendingCount;
  ConnectionState get connectionState => _connectionState;

  void _onConnectivityChanged() {
    _isOffline = !_oracle.isOnline;
    _connectionState = _oracle.state;
    notifyListeners();
    _syncCount();
  }

  Future<void> _syncCount() async {
    final n = await _queue.pendingCount();
    if (_pendingCount != n) {
      _pendingCount = n;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _oracle.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}
