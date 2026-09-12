import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Single item in the sync queue. Serialized to SQLite for crash survival.
class SyncQueueItem {
  final int? id;
  final String operation; // INSERT | UPDATE | DELETE | RPC
  final String
  targetTable; // Supabase table name (or RPC function name for RPC ops)
  final Map<String, dynamic> payload; // JSON body to send (or RPC params)
  final int retryCount;
  final String status; // pending | in_progress | failed | done
  final DateTime createdAt;

  const SyncQueueItem({
    this.id,
    required this.operation,
    required this.targetTable,
    required this.payload,
    this.retryCount = 0,
    this.status = 'pending',
    required this.createdAt,
  });

  SyncQueueItem copyWith({int? retryCount, String? status}) => SyncQueueItem(
    id: id,
    operation: operation,
    targetTable: targetTable,
    payload: payload,
    retryCount: retryCount ?? this.retryCount,
    status: status ?? this.status,
    createdAt: createdAt,
  );
}

/// Persistent sync queue backed by SQLite.
/// §3.2: Survives crashes and app restarts.
/// FIFO order. Failed items don't block the queue.
class SyncQueue {
  static Database? _db;
  static bool _init = false;
  static const _maxRetries = 5;
  static const _doneTTL = Duration(hours: 48);

  Future<Database?> _database() async {
    if (kIsWeb) return null;
    if (_init) return _db;
    _init = true;
    try {
      final dbPath = p.join(await getDatabasesPath(), 'eduquest_sync.db');
      _db = await openDatabase(
        dbPath,
        version: 2,
        onConfigure: (db) async {
          await db.rawQuery('PRAGMA journal_mode=WAL;');
          await db.rawQuery('PRAGMA synchronous=NORMAL;');
        },
        onCreate: (db, _) async {
          await db.execute('''
            create table sync_queue(
              id integer primary key autoincrement,
              operation text not null check(operation in ('INSERT','UPDATE','DELETE','RPC')),
              target_table text not null,
              payload text not null,
              retry_count integer not null default 0,
              status text not null default 'pending' check(status in ('pending','in_progress','failed','done')),
              created_at integer not null
            )
          ''');
          await db.execute(
            'create index if not exists idx_sync_status on sync_queue(status)',
          );
          await db.execute(
            'create index if not exists idx_sync_created on sync_queue(created_at)',
          );
        },
      );
    } catch (_) {}
    return _db;
  }

  /// Enqueue a user action. Always succeeds (writes locally first).
  Future<void> enqueue({
    required String operation,
    required String targetTable,
    required Map<String, dynamic> payload,
  }) async {
    final db = await _database();
    if (db == null) return;
    try {
      await db.insert('sync_queue', {
        'operation': operation,
        'target_table': targetTable,
        'payload': jsonEncode(payload),
        'retry_count': 0,
        'status': 'pending',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  /// Peek next pending item (oldest first). Returns null if queue is empty.
  Future<SyncQueueItem?> peek() async {
    final db = await _database();
    if (db == null) return null;
    try {
      final rows = await db.query(
        'sync_queue',
        where: "status = 'pending'",
        orderBy: 'created_at asc',
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return _fromRow(rows.first);
    } catch (_) {
      return null;
    }
  }

  /// Mark item as in_progress (mutex to avoid double-processing).
  Future<void> markInProgress(int id) async {
    final db = await _database();
    if (db == null) return;
    try {
      await db.update(
        'sync_queue',
        {'status': 'in_progress'},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (_) {}
  }

  /// Mark item as done (will be purged after 48h).
  Future<void> markDone(int id) async {
    final db = await _database();
    if (db == null) return;
    try {
      await db.update(
        'sync_queue',
        {'status': 'done'},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (_) {}
  }

  /// Mark item as failed after max retries.
  Future<void> markFailed(int id) async {
    final db = await _database();
    if (db == null) return;
    try {
      await db.update(
        'sync_queue',
        {'status': 'failed'},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (_) {}
  }

  /// Increment retry count. Returns true if under limit, false if exceeded.
  Future<bool> incrementRetry(int id, int currentCount) async {
    final db = await _database();
    if (db == null) return false;
    final next = currentCount + 1;
    if (next >= _maxRetries) {
      await markFailed(id);
      return false;
    }
    try {
      await db.update(
        'sync_queue',
        {'retry_count': next, 'status': 'pending'},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (_) {}
    return true;
  }

  Future<List<SyncQueueItem>> listPending({
    required String operation,
    required String targetTable,
    required int limit,
  }) async {
    final db = await _database();
    if (db == null) return const [];
    try {
      final rows = await db.query(
        'sync_queue',
        where: 'status = ? and operation = ? and target_table = ?',
        whereArgs: ['pending', operation, targetTable],
        orderBy: 'created_at asc',
        limit: limit,
      );
      return rows
          .map(_fromRow)
          .whereType<SyncQueueItem>()
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  /// Count pending items (for UI badge).
  Future<int> pendingCount() async {
    final db = await _database();
    if (db == null) return 0;
    try {
      final rows = await db.rawQuery(
        "select count(*) as cnt from sync_queue where status in ('pending','in_progress')",
      );
      return rows.isEmpty ? 0 : (rows.first['cnt'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Purge done items older than 48h and failed items older than 7 days.
  Future<void> purgeOld() async {
    final db = await _database();
    if (db == null) return;
    try {
      final doneCutoff = DateTime.now()
          .subtract(_doneTTL)
          .millisecondsSinceEpoch;
      await db.delete(
        'sync_queue',
        where: "status = 'done' and created_at < ?",
        whereArgs: [doneCutoff],
      );
      final failedCutoff = DateTime.now()
          .subtract(const Duration(days: 7))
          .millisecondsSinceEpoch;
      await db.delete(
        'sync_queue',
        where: "status = 'failed' and created_at < ?",
        whereArgs: [failedCutoff],
      );
    } catch (_) {}
  }

  /// Reset any stuck in_progress items back to pending (crash recovery).
  Future<void> resetStuck() async {
    final db = await _database();
    if (db == null) return;
    try {
      await db.update('sync_queue', {
        'status': 'pending',
      }, where: "status = 'in_progress'");
    } catch (_) {}
  }

  SyncQueueItem? _fromRow(Map<String, dynamic> row) {
    try {
      return SyncQueueItem(
        id: row['id'] as int,
        operation: row['operation'] as String,
        targetTable: row['target_table'] as String,
        payload: Map<String, dynamic>.from(
          jsonDecode(row['payload'] as String) as Map,
        ),
        retryCount: row['retry_count'] as int? ?? 0,
        status: row['status'] as String? ?? 'pending',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          row['created_at'] as int? ?? 0,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
    _init = false;
  }
}
