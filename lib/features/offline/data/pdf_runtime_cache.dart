import 'package:eduquest/features/offline/data/encrypted_pdf_cache.dart';
import 'package:eduquest/features/offline/data/pdf_offline_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PdfRuntimeCache {
  PdfRuntimeCache()
    : _store = const FlutterSecureStorage(),
      _repo = PdfOfflineRepository(EncryptedPdfCache());
  final FlutterSecureStorage _store;
  final PdfOfflineRepository _repo;

  Future<List<int>?> load(String url) async {
    final id = _resourceId(url);
    final old = await _store.read(key: _versionKey(id));
    if (old == null) return null;
    return _repo.readPdf(id, old);
  }

  Future<List<int>?> sync(String url) async {
    final id = _resourceId(url);
    final old = await _store.read(key: _versionKey(id));
    final version = _version(url);
    final ok = await _repo.syncPdf(
      resourceId: id,
      pdfUrl: url,
      version: version,
      oldVersion: old,
    );
    if (!ok) {
      if (old == null) return null;
      return _repo.readPdf(id, old);
    }
    await _store.write(key: _versionKey(id), value: version);
    return _repo.readPdf(id, version);
  }

  String _resourceId(String url) {
    final u = Uri.tryParse(url);
    if (u == null) return 'pdf_${_hash(url)}';
    final base = '${u.scheme}://${u.host}${u.path}';
    return 'pdf_${_hash(base)}';
  }

  String _version(String url) => _hash(url);
  String _versionKey(String id) => 'pdf_runtime_ver_$id';

  String _hash(String input) {
    var h = 2166136261;
    for (final c in input.codeUnits) {
      h ^= c;
      h = (h * 16777619) & 0x7fffffff;
    }
    return h.toRadixString(16);
  }
}
