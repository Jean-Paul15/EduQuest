import 'dart:async';
import 'package:eduquest/shared/core/app_constants.dart';
import 'package:eduquest/shared/network/connectivity_oracle.dart';
import 'package:eduquest/shared/sync/sync_queue.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Processes the SyncQueue when connectivity is confirmed.
/// §3.2: Listens to ConnectivityOracle, drains queue FIFO,
/// retry with exponential backoff (1s,2s,4s,8s,16s), max 5 retries.
class SyncService {
  final SyncQueue _queue;
  final ConnectivityOracle _oracle;
  VoidCallback? onSyncComplete;

  SyncService({required SyncQueue queue, required ConnectivityOracle oracle})
    : _queue = queue,
      _oracle = oracle;

  Timer? _drainTimer;
  bool _draining = false;
  bool _listening = false;

  static const _retryDelays = [1, 2, 4, 8, 16]; // seconds, exponential backoff

  /// Start listening to connectivity changes.
  void start() {
    if (!_listening) {
      _oracle.addListener(_onConnectivityChanged);
      _listening = true;
    }
    _queue.resetStuck();
    _queue.purgeOld();
    if (_oracle.canSync) _scheduleDrain();
  }

  /// Stop listening.
  void stop() {
    if (_listening) {
      _oracle.removeListener(_onConnectivityChanged);
      _listening = false;
    }
    _drainTimer?.cancel();
  }

  void _onConnectivityChanged() {
    if (_oracle.canSync && !_draining) _scheduleDrain();
  }

  void _scheduleDrain() {
    _drainTimer?.cancel();
    _drainTimer = Timer(const Duration(milliseconds: 300), _drain);
  }

  void tryFlushNow() {
    if (_oracle.canSync && !_draining) unawaited(_drain());
  }

  Future<void> _drain() async {
    if (_draining || !_oracle.canSync) return;
    _draining = true;
    int drained = 0;
    try {
      final client = Supabase.instance.client;
      while (_oracle.canSync &&
          (_oracle.state != ConnectionState.slowConnection || drained < 3)) {
        final item = await _queue.peek();
        if (item == null || item.id == null) break;
        if (item.operation == SyncOp.rpc &&
            item.targetTable == AppRpc.ingestAppEvents) {
          final sent = await _sendAnalyticsBatch(client);
          if (sent > 0) {
            drained += sent;
            continue;
          }
        }
        await _queue.markInProgress(item.id!);

        final ok = await _sendItem(client, item);
        if (ok) {
          await _queue.markDone(item.id!);
          drained++;
        } else {
          final canRetry = await _queue.incrementRetry(
            item.id!,
            item.retryCount,
          );
          if (!canRetry) {
            // Max retries reached — item is now failed
            debugPrint(
              'SyncService: item ${item.id} failed after ${item.retryCount + 1} attempts',
            );
          } else {
            // Wait before next attempt
            final delay =
                _retryDelays[item.retryCount.clamp(0, _retryDelays.length - 1)];
            await Future<void>.delayed(Duration(seconds: delay));
          }
        }
      }
      await _queue.purgeOld();
    } catch (error, stack) {
      _recordError(error, stack, 'sync_queue_drain');
    }
    _draining = false;
    onSyncComplete?.call();
  }

  Future<int> _sendAnalyticsBatch(SupabaseClient client) async {
    final items = await _queue.listPending(
      operation: SyncOp.rpc,
      targetTable: AppRpc.ingestAppEvents,
      limit: 25,
    );
    if (items.isEmpty) return 0;
    for (final item in items) {
      if (item.id != null) await _queue.markInProgress(item.id!);
    }
    try {
      await client.rpc(
        AppRpc.ingestAppEvents,
        params: {
          'batch': items.map((item) => item.payload).toList(growable: false),
        },
      );
      for (final item in items) {
        if (item.id != null) await _queue.markDone(item.id!);
      }
      return items.length;
    } catch (error, stack) {
      _recordError(error, stack, 'analytics_batch');
      for (final item in items) {
        if (item.id != null) {
          await _queue.incrementRetry(item.id!, item.retryCount);
        }
      }
      return 0;
    }
  }

  Future<bool> _sendItem(SupabaseClient client, SyncQueueItem item) async {
    if (!Env.hasSupabase) return false;
    try {
      switch (item.operation) {
        case 'INSERT':
          await client.from(item.targetTable).insert(item.payload);
          return true;
        case 'UPDATE':
          final id = item.payload['id'];
          if (id == null) return false;
          await client.from(item.targetTable).update(item.payload).eq('id', id);
          return true;
        case 'DELETE':
          final id = item.payload['id'];
          if (id == null) return false;
          await client.from(item.targetTable).delete().eq('id', id);
          return true;
        case 'RPC':
          // targetTable holds the RPC function name, payload holds params
          await client.rpc(item.targetTable, params: item.payload);
          return true;
        default:
          return false;
      }
    } catch (_) {
      return false;
    }
  }

  /// Convenience: enqueue an action and trigger drain if online.
  Future<void> enqueueAndTryFlush({
    required String operation,
    required String targetTable,
    required Map<String, dynamic> payload,
  }) async {
    await _queue.enqueue(
      operation: operation,
      targetTable: targetTable,
      payload: payload,
    );
    if (_oracle.canSync && !_draining) unawaited(_drain());
  }

  void _recordError(Object error, StackTrace stack, String reason) {
    if (kDebugMode) debugPrint('SyncService[$reason]: $error');
    unawaited(
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: reason,
        fatal: false,
      ),
    );
  }
}
