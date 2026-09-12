import 'dart:convert';
import 'package:eduquest/shared/data/local_json_cache_sqlite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalJsonCache {
  final _sqlite = LocalJsonCacheSqlite();
  static final Map<String, List<Map<String, dynamic>>> _mem = {};
  static final Map<String, int> _memTs = {};

  List<Map<String, dynamic>>? _decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> _clone(List<Map<String, dynamic>> list) =>
      list.map((e) => Map<String, dynamic>.from(e)).toList(growable: false);

  Future<List<Map<String, dynamic>>?> readList(String key) async {
    final m = _mem[key];
    if (m != null) return _clone(m);
    try {
      final fromDb = _decode(await _sqlite.readRaw(key));
      if (fromDb != null) {
        _mem[key] = fromDb;
        final dbTs = await _sqlite.readUpdatedAt(key);
        if (dbTs != null) _memTs[key] = dbTs;
        return _clone(fromDb);
      }
      final raw = (await SharedPreferences.getInstance()).getString(key);
      final fromPrefs = _decode(raw);
      if (fromPrefs == null) return null;
      _mem[key] = fromPrefs;
      final p = await SharedPreferences.getInstance();
      final prefTs = p.getInt('$key::ts');
      if (prefTs != null) _memTs[key] = prefTs;
      await _sqlite.writeRaw(key, jsonEncode(fromPrefs));
      return _clone(fromPrefs);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isFresh(String key, Duration maxAge) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final ts = await lastUpdatedMs(key);
    if (ts == null) return false;
    return now - ts <= maxAge.inMilliseconds;
  }

  Future<int?> lastUpdatedMs(String key) async {
    final mem = _memTs[key];
    if (mem != null) return mem;
    final db = await _sqlite.readUpdatedAt(key);
    if (db != null) {
      _memTs[key] = db;
      return db;
    }
    final prefs = await SharedPreferences.getInstance();
    final p = prefs.getInt('$key::ts');
    if (p != null) _memTs[key] = p;
    return p;
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> list) async {
    final snapshot = _clone(list);
    _mem[key] = snapshot;
    final ts = DateTime.now().millisecondsSinceEpoch;
    _memTs[key] = ts;
    final raw = jsonEncode(snapshot);
    try {
      await _sqlite.writeRaw(key, raw);
      final p = await SharedPreferences.getInstance();
      await p.setString(key, raw);
      await p.setInt('$key::ts', ts);
    } catch (_) {}
  }

  Future<bool> hasKey(String key) async {
    if (_mem.containsKey(key)) return true;
    if (await _sqlite.readUpdatedAt(key) != null) return true;
    final p = await SharedPreferences.getInstance();
    return p.containsKey(key);
  }

  Future<void> removeByPrefix(String prefix) async {
    _mem.removeWhere((k, _) => k.startsWith(prefix));
    _memTs.removeWhere((k, _) => k.startsWith(prefix));
    try {
      await _sqlite.removeByPrefix(prefix);
      final p = await SharedPreferences.getInstance();
      for (final k in p.getKeys().where((k) => k.startsWith(prefix)).toList()) {
        await p.remove(k);
      }
    } catch (_) {}
  }

  Future<void> removeByPrefixes(List<String> prefixes) async {
    for (final prefix in prefixes) {
      await removeByPrefix(prefix);
    }
  }

  /// Vide entièrement le cache JSON local (toutes les clés, tous les
  /// domaines) -- action "vider le cache" explicite de l'utilisateur. Un
  /// préfixe vide matche toute clé dans les trois couches de stockage.
  Future<void> clearAll() => removeByPrefix('');
}
