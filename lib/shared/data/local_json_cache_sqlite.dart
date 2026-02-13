import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalJsonCacheSqlite {
  static Database? _db;
  static bool _dbInit = false;

  Future<Database?> _database() async {
    if (kIsWeb) return null;
    if (_dbInit) return _db;
    _dbInit = true;
    try {
      final dbPath = join(await getDatabasesPath(), 'eduquest_cache.db');
      _db = await openDatabase(
        dbPath,
        version: 1,
        onConfigure: (db) async {
          await db.rawQuery('PRAGMA journal_mode=WAL;');
          await db.rawQuery('PRAGMA synchronous=NORMAL;');
          await db.rawQuery('PRAGMA temp_store=MEMORY;');
        },
        onCreate: (db, _) async {
          await db.execute(
            'create table cache_entries('
            'cache_key text primary key,'
            'value text not null,'
            'updated_at integer not null)',
          );
        },
      );
    } catch (_) {}
    return _db;
  }

  Future<String?> readRaw(String key) async {
    final db = await _database();
    if (db == null) return null;
    try {
      final rows = await db.query(
        'cache_entries',
        columns: ['value'],
        where: 'cache_key = ?',
        whereArgs: [key],
        limit: 1,
      );
      return rows.isEmpty ? null : '${rows.first['value']}';
    } catch (_) {
      return null;
    }
  }

  Future<int?> readUpdatedAt(String key) async {
    final db = await _database();
    if (db == null) return null;
    try {
      final rows = await db.query(
        'cache_entries',
        columns: ['updated_at'],
        where: 'cache_key = ?',
        whereArgs: [key],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      final v = rows.first['updated_at'];
      return v is int ? v : int.tryParse('$v');
    } catch (_) {
      return null;
    }
  }

  Future<void> writeRaw(String key, String raw) async {
    final db = await _database();
    if (db == null) return;
    try {
      await db.insert('cache_entries', {
        'cache_key': key,
        'value': raw,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {}
  }

  Future<void> removeByPrefix(String prefix) async {
    final db = await _database();
    if (db == null) return;
    try {
      await db.delete(
        'cache_entries',
        where: 'cache_key like ?',
        whereArgs: ['$prefix%'],
      );
    } catch (_) {}
  }
}
