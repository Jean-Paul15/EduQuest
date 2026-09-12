import 'dart:io';
import 'package:eduquest/shared/core/app_constants.dart';
import 'package:eduquest/shared/core/result.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
class CacheCleanupStats {
  const CacheCleanupStats(
      {required this.filesRemoved, required this.bytesFreed,
       required this.totalCacheBytesAfter});
  final int filesRemoved, bytesFreed, totalCacheBytesAfter;
}
class CacheCleanupService {
  const CacheCleanupService();
  static const _imgTtl = Duration(days: OfflineConfig.imageCacheTtlDays);
  // Les documents et vidéos téléchargés (`.bin` / `.vid`) sont des choix
  // explicites de l'élève : jamais supprimés par ancienneté. Ils ne sont
  // évincés que par le plafond global 5 Go (LRU) ou l'action « vider le cache ».
  static const _keepExts = {'.bin', '.vid'};
  Future<Result<CacheCleanupStats>> runCleanup() async {
    int removed = 0, freed = 0;
    try {
      final dirs = await _cacheDirs();
      final remaining = <({File f, DateTime lm, int sz})>[];
      final now = DateTime.now();
      for (final d in dirs) {
        try {
          await for (final e in d.list(recursive: true)) {
            if (e is! File) continue;
            try {
              final lm = await e.lastModified();
              final sz = await e.length();
              final protected = _keepExts.any(e.path.endsWith);
              if (!protected && now.difference(lm) > _imgTtl) {
                await e.delete();
                removed++;
                freed += sz;
              } else {
                remaining.add((f: e, lm: lm, sz: sz));
              }
            } catch (_) {}
          }
        } catch (_) {}
      }
      final (r2, b2, total) = await _enforceLimit(remaining);
      removed += r2; freed += b2;
      String mb(int v) => (v / 1048576).toStringAsFixed(1);
      debugPrint('CacheCleanup: -$removed, ${mb(freed)} MB freed, ${mb(total)} MB left');
      return success(CacheCleanupStats(
          filesRemoved: removed, bytesFreed: freed,
          totalCacheBytesAfter: total));
    } catch (e) { return failure(StorageError(message: 'Cache cleanup error: $e', cause: e)); }
  }
  Future<List<Directory>> _cacheDirs() async {
    final dirs = <Directory>[];
    try {
      final t = await getTemporaryDirectory();
      final d = Directory('${t.path}/libCachedImageData');
      if (await d.exists()) dirs.add(d);
    } catch (_) {}
    try {
      final a = await getApplicationSupportDirectory();
      final d = Directory('${a.path}/pdf_cache');
      if (await d.exists()) dirs.add(d);
    } catch (_) {}
    try {
      final doc = await getApplicationDocumentsDirectory();
      final d = Directory('${doc.path}/video_cache');
      if (await d.exists()) dirs.add(d);
    } catch (_) {}
    return dirs;
  }
  Future<(int, int, int)> _enforceLimit(
      List<({File f, DateTime lm, int sz})> files) async {
    int total = files.fold(0, (s, x) => s + x.sz), rem = 0, freed = 0;
    if (total <= OfflineConfig.maxTotalCacheBytes) return (0, 0, total);
    files.sort((a, b) => a.lm.compareTo(b.lm));
    for (final x in files) {
      if (total <= OfflineConfig.maxTotalCacheBytes) break;
      try { await x.f.delete(); rem++; freed += x.sz; total -= x.sz; } catch (_) {}
    }
    return (rem, freed, total);
  }
}
