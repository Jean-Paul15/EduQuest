import 'package:eduquest/features/offline/data/encrypted_pdf_cache.dart';
import 'package:eduquest/features/offline/data/pdf_offline_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PdfRuntimeCache {
  PdfRuntimeCache()
    : _store = const FlutterSecureStorage(),
      _repo = PdfOfflineRepository(EncryptedPdfCache());
  static const _refreshInterval = Duration(hours: 12);
  static final Map<String, List<int>> _mem = {};
  final FlutterSecureStorage _store;
  final PdfOfflineRepository _repo;

  Future<List<int>?> load(String url) async {
    final id = _resourceId(url);
    final old = await _store.read(key: _versionKey(id));
    if (old == null) return null;
    final memKey = '$id-$old';
    final mem = _mem[memKey];
    if (mem != null) return mem;
    final out = await _repo.readPdf(id, old);
    if (out != null) _mem[memKey] = out;
    return out;
  }

  Future<List<int>?> sync(String url) async {
    final id = _resourceId(url);
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastSync = int.tryParse(await _store.read(key: _syncKey(id)) ?? '');
    final stale =
        lastSync == null || now - lastSync > _refreshInterval.inMilliseconds;
    final old = await _store.read(key: _versionKey(id));
    final version = _version(url);
    if (!stale && old == version && await _repo.hasPdf(id, version)) {
      final mem = _mem['$id-$version'];
      if (mem != null) return mem;
      final out = await _repo.readPdf(id, version);
      if (out != null) _mem['$id-$version'] = out;
      return out;
    }
    final ok = await _repo.syncPdf(
      resourceId: id,
      pdfUrl: url,
      version: version,
      oldVersion: old,
      forceRefresh: stale,
    );
    if (!ok) {
      if (old == null) return null;
      final out = await _repo.readPdf(id, old);
      if (out != null) _mem['$id-$old'] = out;
      return out;
    }
    await _store.write(key: _versionKey(id), value: version);
    await _store.write(key: _syncKey(id), value: '$now');
    final out = await _repo.readPdf(id, version);
    if (out != null) _mem['$id-$version'] = out;
    if (old != null && old != version) _mem.remove('$id-$old');
    return out;
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
