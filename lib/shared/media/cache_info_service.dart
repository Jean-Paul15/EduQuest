import 'dart:io';
import 'package:eduquest/shared/media/media_cache_service.dart';
import 'package:path_provider/path_provider.dart';
class CacheInfo {
  const CacheInfo(
      {required this.imageBytes, required this.pdfBytes,
       required this.videoBytes, required this.otherBytes,
       required this.totalBytes});
  final int imageBytes, pdfBytes, videoBytes, otherBytes, totalBytes;
}
class CacheInfoService {
  const CacheInfoService();
  Future<CacheInfo> getCacheInfo() async {
    int img = 0, pdf = 0, vid = 0;
    try {
      final tmp = await getTemporaryDirectory();
      img = await _dirSize(Directory('${tmp.path}/libCachedImageData'));
    } catch (_) {}
    try {
      final app = await getApplicationSupportDirectory();
      pdf = await _dirSize(Directory('${app.path}/pdf_cache'));
    } catch (_) {}
    try {
      final doc = await getApplicationDocumentsDirectory();
      vid = await _dirSize(Directory('${doc.path}/video_cache'));
    } catch (_) {}
    return CacheInfo(
        imageBytes: img, pdfBytes: pdf, videoBytes: vid,
        otherBytes: 0, totalBytes: img + pdf + vid);
  }
  Future<void> clearAllCaches() async {
    try {
      final tmp = await getTemporaryDirectory();
      final img = Directory('${tmp.path}/libCachedImageData');
      if (await img.exists()) await img.delete(recursive: true);
    } catch (_) {}
    try {
      final doc = await getApplicationDocumentsDirectory();
      final vid = Directory('${doc.path}/video_cache');
      if (await vid.exists()) await vid.delete(recursive: true);
    } catch (_) {}
    await MediaCacheService().clearCache();
  }
  Future<int> _dirSize(Directory dir) async {
    int size = 0;
    try {
      if (!await dir.exists()) return 0;
      await for (final e in dir.list(recursive: true)) {
        if (e is File) {
          try { size += await e.length(); } catch (_) {}
        }
      }
    } catch (_) {}
    return size;
  }
}
