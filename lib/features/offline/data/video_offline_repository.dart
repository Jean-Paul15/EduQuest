import 'dart:io';
import 'package:eduquest/features/offline/data/encrypted_video_cache.dart';
import 'package:eduquest/shared/sync/service_locator.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class VideoOfflineRepository {
  VideoOfflineRepository(this._cache);
  final EncryptedVideoCache _cache;

  Future<String?> prepareForPlayback(String url) async {
    final key = _cacheKey(url);
    final bytes = await _cache.read(key);
    if (bytes == null) return null;
    final tmp = File('${Directory.systemTemp.path}/eduquest_vid_${key.hashCode}.mp4');
    await tmp.writeAsBytes(bytes, flush: true);
    return tmp.path;
  }

  Future<bool> downloadVideo(String url,
      {void Function(int downloaded, int total)? onProgress}) async {
    final key = _cacheKey(url);
    if (await _cache.exists(key)) return true;
    if (!ServiceLocator().oracle.canDownloadMedia) return false;
    try {
      final client = http.Client();
      final req = http.Request('GET', Uri.parse(url));
      final res = await client.send(req);
      final total = res.contentLength ?? 0;
      final bytes = <int>[];
      int done = 0;
      await for (final chunk in res.stream) {
        bytes.addAll(chunk);
        done += chunk.length;
        onProgress?.call(done, total);
      }
      client.close();
      if (bytes.isEmpty) return false;
      await _cache.save(key, bytes);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isDownloaded(String url) => _cache.exists(_cacheKey(url));

  Future<void> deleteVideo(String url) => _cache.delete(_cacheKey(url));

  Future<List<({String key, int size})>> listDownloadedVideos() async {
    final out = <({String key, int size})>[];
    try {
      final dir = await _videoDir();
      if (!await dir.exists()) return out;
      await for (final e in dir.list()) {
        if (e is File && e.path.endsWith('.vid')) {
          try {
            out.add((key: e.path, size: await e.length()));
          } catch (_) {}
        }
      }
    } catch (_) {}
    return out;
  }

  Future<int> totalDownloadedBytes() async {
    int total = 0;
    try {
      final dir = await _videoDir();
      if (!await dir.exists()) return 0;
      await for (final e in dir.list(recursive: true)) {
        if (e is File) {
          try { total += await e.length(); } catch (_) {}
        }
      }
    } catch (_) {}
    return total;
  }

  Future<Directory> _videoDir() async {
    final app = await getApplicationDocumentsDirectory();
    return Directory('${app.path}/video_cache');
  }

  String _cacheKey(String url) {
    final u = Uri.tryParse(url);
    final base = u != null ? '${u.scheme}//${u.host}${u.path}' : url;
    var h = 2166136261;
    for (final c in base.codeUnits) {
      h ^= c;
      h = (h * 16777619) & 0x7fffffff;
    }
    return 'vid_${h.toRadixString(16)}';
  }
}
