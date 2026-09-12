import 'package:eduquest/features/offline/data/encrypted_pdf_cache.dart';
import 'package:http/http.dart' as http;

/// Octets d'un PDF plus l'indication de fraîcheur : `fresh` vrai = version
/// courante fraîchement obtenue (la version peut être persistée) ; faux = repli
/// sur une version antérieure encore en cache.
typedef PdfSyncResult = ({List<int>? bytes, bool fresh});

class PdfOfflineRepository {
  PdfOfflineRepository(this._cache);
  final EncryptedPdfCache _cache;

  static const _timeout = Duration(seconds: 30);
  static const _maxAttempts = 2;

  Future<PdfSyncResult> syncPdf({
    required String resourceId,
    required String pdfUrl,
    required String version,
    required String? oldVersion,
    bool forceRefresh = false,
  }) async {
    final newKey = '$resourceId-$version';
    if (!forceRefresh && oldVersion == version && await _cache.exists(newKey)) {
      return (bytes: await _cache.read(newKey), fresh: true);
    }
    final bytes = await _download(pdfUrl);
    if (bytes == null) {
      return (bytes: await _fallback(resourceId, oldVersion), fresh: false);
    }
    // L'échec d'écriture du cache (keystore/disque indisponible) ne doit pas
    // priver l'élève du document : on sert quand même les octets téléchargés.
    try {
      await _cache.save(newKey, bytes);
      if (oldVersion != null && oldVersion != version) {
        await _cache.delete('$resourceId-$oldVersion');
      }
    } catch (_) {}
    return (bytes: bytes, fresh: true);
  }

  Future<List<int>?> _download(String pdfUrl) async {
    final uri = Uri.tryParse(pdfUrl);
    if (uri == null) return null;
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final res = await http.get(uri).timeout(_timeout);
        if (res.statusCode >= 400 || res.bodyBytes.isEmpty) return null;
        return res.bodyBytes;
      } catch (_) {
        if (attempt == _maxAttempts) return null;
      }
    }
    return null;
  }

  Future<List<int>?> _fallback(String resourceId, String? oldVersion) async {
    if (oldVersion == null) return null;
    return _cache.read('$resourceId-$oldVersion');
  }

  Future<List<int>?> readPdf(String resourceId, String version) {
    return _cache.read('$resourceId-$version');
  }

  Future<bool> hasPdf(String resourceId, String version) {
    return _cache.exists('$resourceId-$version');
  }
}
