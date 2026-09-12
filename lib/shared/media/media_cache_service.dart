import 'dart:io';
import 'dart:typed_data';
import 'package:eduquest/features/offline/data/pdf_runtime_cache.dart';
import 'package:eduquest/shared/core/result.dart';
import 'package:eduquest/shared/sync/service_locator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

/// Unified media caching service that delegates to the existing
/// [PdfRuntimeCache] (which internally uses [EncryptedPdfCache] and [PdfOfflineRepository]).
class MediaCacheService {
  MediaCacheService()
    : _runtime = PdfRuntimeCache(),
      _store = const FlutterSecureStorage();

  final PdfRuntimeCache _runtime;
  final FlutterSecureStorage _store;

  /// Return cached bytes or download, encrypt, and cache.
  Future<Result<Uint8List>> getMedia(
    String mediaId,
    String url, {
    String? contentType,
  }) async {
    try {
      final cached = await _runtime.load(url);
      if (cached != null) return success(Uint8List.fromList(cached));
      if (!ServiceLocator().oracle.canDownloadMedia) {
        return failure(NetworkError(message: 'Téléchargement bloqué sur connexion mobile'));
      }
      final synced = await _runtime.sync(url);
      if (synced != null) return success(Uint8List.fromList(synced));
      return failure(StorageError(message: 'Failed to load media: $mediaId'));
    } catch (e) {
      return failure(StorageError(message: e.toString(), cause: e));
    }
  }

  /// Explicitly preload media for offline use.
  Future<Result<void>> preloadMedia(String mediaId, String url) async {
    try {
      if (!ServiceLocator().oracle.canDownloadMedia) {
        return failure(NetworkError(message: 'Téléchargement bloqué sur connexion mobile'));
      }
      final synced = await _runtime.sync(url);
      if (synced == null) return failure(StorageError(message: 'Preload failed: $mediaId'));
      return success(null);
    } catch (e) {
      return failure(StorageError(message: e.toString(), cause: e));
    }
  }

  /// Check whether any version of [mediaId] exists in the local cache.
  Future<bool> isCached(String mediaId) async {
    final d = await _cacheDir();
    return await d.exists() && d.listSync().any((e) => e is File && e.path.endsWith('.bin') && e.uri.pathSegments.last.startsWith(mediaId));
  }

  /// Clear cached media. Omit [mediaId] to clear everything.
  Future<Result<void>> clearCache({String? mediaId}) async {
    try {
      final d = await _cacheDir();
      if (!await d.exists()) return success(null);
      if (mediaId == null) {
        await d.delete(recursive: true);
        await _clearVersionKeys(null);
      } else {
        for (final e in d.listSync()) { if (e is File && e.uri.pathSegments.last.startsWith(mediaId) && e.path.endsWith('.bin')) await e.delete(); }
        await _clearVersionKeys(mediaId);
      }
      return success(null);
    } catch (e) {
      return failure(StorageError(message: e.toString(), cause: e));
    }
  }

  /// Total size of the encrypted cache on disk, in bytes.
  Future<int> cacheSizeBytes() async {
    final d = await _cacheDir();
    if (!await d.exists()) return 0;
    int total = 0;
    for (final e in d.listSync()) { if (e is File) total += await e.length(); }
    return total;
  }

  Future<Directory> _cacheDir() async => Directory('${(await getApplicationSupportDirectory()).path}/pdf_cache');

  Future<void> _clearVersionKeys(String? prefix) async {
    final target = prefix ?? 'pdf_runtime';
    for (final k in (await _store.readAll()).keys) { if (k.contains(target)) await _store.delete(key: k); }
  }
}
