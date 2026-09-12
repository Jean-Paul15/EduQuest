import 'package:eduquest/features/offline/data/encrypted_pdf_cache.dart';
import 'package:eduquest/features/offline/data/pdf_offline_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache runtime des PDF. Le pointeur de version et l'horodatage de sync vivent
/// dans `SharedPreferences` (donnée non secrète, fiable au redémarrage) et non
/// plus dans le secure storage, qui pouvait renvoyer `null` sur un cold start
/// Android et faire croire qu'un document telecharge n'etait plus disponible.
/// En dernier recours, si le pointeur manque, on retrouve le document en
/// scannant les fichiers chiffres deja presents sur le disque.
class PdfRuntimeCache {
  PdfRuntimeCache()
    : _legacy = const FlutterSecureStorage(),
      _cache = EncryptedPdfCache(),
      _repo = PdfOfflineRepository(EncryptedPdfCache());
  static const _refreshInterval = Duration(hours: 12);
  static final Map<String, List<int>> _mem = {};
  final FlutterSecureStorage _legacy;
  final EncryptedPdfCache _cache;
  final PdfOfflineRepository _repo;

  Future<List<int>?> load(String url) async {
    final id = _resourceId(url);
    final version = await _resolveVersion(id);
    if (version == null) return null;
    final memKey = '$id-$version';
    final mem = _mem[memKey];
    if (mem != null) return mem;
    final out = await _repo.readPdf(id, version);
    if (out != null && out.isNotEmpty) _mem[memKey] = out;
    return out;
  }

  Future<List<int>?> sync(String url) async {
    final id = _resourceId(url);
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastSync = int.tryParse(await _read(_syncKey(id)) ?? '');
    final stale =
        lastSync == null || now - lastSync > _refreshInterval.inMilliseconds;
    final old = await _resolveVersion(id);
    final version = _version(url);
    if (!stale && old == version && await _repo.hasPdf(id, version)) {
      final mem = _mem['$id-$version'];
      if (mem != null) return mem;
      final out = await _repo.readPdf(id, version);
      if (out != null) _mem['$id-$version'] = out;
      return out;
    }
    final res = await _repo.syncPdf(
      resourceId: id,
      pdfUrl: url,
      version: version,
      oldVersion: old,
      forceRefresh: stale,
    );
    final bytes = res.bytes;
    if (bytes == null || bytes.isEmpty) return null;
    if (res.fresh) {
      await _write(_versionKey(id), version);
      await _write(_syncKey(id), '$now');
      _mem['$id-$version'] = bytes;
      if (old != null && old != version) _mem.remove('$id-$old');
    } else if (old != null) {
      _mem['$id-$old'] = bytes;
    }
    return bytes;
  }

  Future<bool> hasCached(String url) async {
    final id = _resourceId(url);
    final version = await _resolveVersion(id);
    if (version == null) return false;
    if (_mem.containsKey('$id-$version')) return true;
    return _repo.hasPdf(id, version);
  }

  /// Pointeur de version : prefs -> migration depuis l'ancien secure storage ->
  /// repli sur le fichier chiffre le plus recent present sur le disque.
  Future<String?> _resolveVersion(String id) async {
    final fromPrefs = await _read(_versionKey(id));
    if (fromPrefs != null && fromPrefs.isNotEmpty) return fromPrefs;

    String? legacy;
    try {
      legacy = await _legacy.read(key: 'pdf_runtime_ver_$id');
    } catch (_) {}
    if (legacy != null && legacy.isNotEmpty) {
      await _write(_versionKey(id), legacy);
      return legacy;
    }

    final keys = await _cache.keysWithPrefix('$id-');
    if (keys.isEmpty) return null;
    keys.sort();
    final recovered = keys.last.substring(id.length + 1);
    await _write(_versionKey(id), recovered);
    return recovered;
  }

  Future<String?> _read(String key) async {
    try {
      return (await SharedPreferences.getInstance()).getString(key);
    } catch (_) {
      return null;
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await (await SharedPreferences.getInstance()).setString(key, value);
    } catch (_) {}
  }

  String _resourceId(String url) {
    final u = Uri.tryParse(url);
    if (u == null) return 'pdf_${_hash(url)}';
    final base = '${u.scheme}://${u.host}${u.path}';
    return 'pdf_${_hash(base)}';
  }

  String _version(String url) {
    final u = Uri.tryParse(url);
    if (u == null) return _hash(url);
    final tracked = <String, String>{};
    for (final k in ['v', 'version', 'rev', 'updated', 'updated_at']) {
      final v = u.queryParameters[k];
      if (v != null && v.isNotEmpty) tracked[k] = v;
    }
    final base = '${u.scheme}://${u.host}${u.path}';
    if (tracked.isEmpty) return _hash(base);
    final out = tracked.entries.map((e) => '${e.key}=${e.value}').join('&');
    return _hash('$base?$out');
  }

  String _versionKey(String id) => 'pdf_runtime_ver_$id';
  String _syncKey(String id) => 'pdf_runtime_sync_$id';

  String _hash(String input) {
    var h = 2166136261;
    for (final c in input.codeUnits) {
      h ^= c;
      h = (h * 16777619) & 0x7fffffff;
    }
    return h.toRadixString(16);
  }
}
