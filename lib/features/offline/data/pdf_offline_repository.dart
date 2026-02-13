import 'package:eduquest/features/offline/data/encrypted_pdf_cache.dart';
import 'package:http/http.dart' as http;

class PdfOfflineRepository {
  PdfOfflineRepository(this._cache);
  final EncryptedPdfCache _cache;

  Future<bool> syncPdf({
    required String resourceId,
    required String pdfUrl,
    required String version,
    required String? oldVersion,
  }) async {
    final newKey = '$resourceId-$version';
    if (oldVersion == version && await _cache.exists(newKey)) return true;
    try {
      final res = await http.get(Uri.parse(pdfUrl)).timeout(const Duration(seconds: 20));
      if (res.statusCode >= 400 || res.bodyBytes.isEmpty) return await _fallback(resourceId, oldVersion);
      await _cache.save(newKey, res.bodyBytes);
      if (oldVersion != null && oldVersion != version) {
        await _cache.delete('$resourceId-$oldVersion');
      }
      return true;
    } catch (_) {
      return _fallback(resourceId, oldVersion);
    }
  }

  Future<bool> _fallback(String resourceId, String? oldVersion) async {
    if (oldVersion == null) return false;
    return _cache.exists('$resourceId-$oldVersion');
  }

  Future<List<int>?> readPdf(String resourceId, String version) {
    return _cache.read('$resourceId-$version');
  }

  Future<bool> hasPdf(String resourceId, String version) {
    return _cache.exists('$resourceId-$version');
  }
}
