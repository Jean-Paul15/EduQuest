import 'dart:async';
import 'package:eduquest/features/videos/domain/chapter_video.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/data/storage_url_resolver.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eduquest/shared/realtime/cache_signal.dart';

class VideoRepository {
  VideoRepository();

  final _local = LocalJsonCache();
  static final Map<String, List<ChapterVideo>> _mem = {};


  static void clearMemory() => _mem.clear();

  List<ChapterVideo>? peek(String levelCode, String serieCode) =>
      _mem[_key(levelCode, serieCode)];

  Future<bool> hasCache(String levelCode, String serieCode) async {
    if (_mem.containsKey(_key(levelCode, serieCode))) return true;
    return _local.hasKey(_key(levelCode, serieCode));
  }

  /// Purge ciblee RAM pour l'invalidation temps reel.
  static void evictKeys(CacheTargets t) {
    for (final k in t.exact) {
      _mem.remove(k);
    }
    for (final p in t.prefixes) {
      _mem.removeWhere((k, _) => k.startsWith(p));
    }
  }

  Future<List<ChapterVideo>> byLevelAndSerie({
    required String levelCode,
    required String serieCode,
    bool forceRefresh = false,
  }) async {
    final key = _key(levelCode, serieCode);
    final mem = _mem[key];
    if (mem != null && !forceRefresh) {
      return mem;
    }
    final local = await _fromLocal(key);
    if (local.isNotEmpty) _mem[key] = local;
    if (!Env.hasSupabase || forceRefresh) {
      return forceRefresh
          ? (await _refresh(
                  levelCode: levelCode,
                  serieCode: serieCode,
                  key: key,
                )) ??
                local
          : local;
    }
    if (local.isNotEmpty) {
      return local;
    }
    return (await _refresh(
          levelCode: levelCode,
          serieCode: serieCode,
          key: key,
        )) ??
        local;
  }

  Future<List<ChapterVideo>> _fromLocal(String key) async {
    final rows = await _local.readList(key);
    if (rows == null) return const [];
    return rows
        .map(
          (e) => ChapterVideo(
            id: '${e['id']}',
            chapter: '${e['chapter']}',
            title: '${e['title']}',
            url: '${e['url']}',
            sharedAcrossLevels: e['sharedAcrossLevels'] as bool? ?? false,
          ),
        )
        .toList();
  }

  Future<List<ChapterVideo>?> _refresh({
    required String levelCode,
    required String serieCode,
    required String key,
  }) async {
    try {
      final rows = await Supabase.instance.client.rpc(
        'list_my_series_resources',
        params: {
          'p_types': ['video', 'youtube'],
        },
      );
      final out =
          (rows as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .map((e) {
                final url = '${e['external_url'] ?? resolveContentUrl(e['storage_path']?.toString()) ?? ''}';
                return ChapterVideo(
                  id: '${e['id']}',
                  chapter: '${e['chapter_title'] ?? 'Chapitre'}',
                  title: '${e['title']}',
                  url: url,
                  sharedAcrossLevels: e['shared_across_series'] == true,
                );
              })
              .where((v) => v.url.isNotEmpty)
              .toList()
            ..sort((a, b) {
              final chapter = a.chapter.toLowerCase().compareTo(
                b.chapter.toLowerCase(),
              );
              return chapter != 0
                  ? chapter
                  : a.title.toLowerCase().compareTo(b.title.toLowerCase());
            });
      _mem[key] = out;
      await _local.writeList(
        key,
        out
            .map(
              (e) => {
                'id': e.id,
                'chapter': e.chapter,
                'title': e.title,
                'url': e.url,
                'sharedAcrossLevels': e.sharedAcrossLevels,
              },
            )
            .toList(),
      );
      return out;
    } catch (_) {
      return null;
    }
  }

  String _key(String levelCode, String serieCode) =>
      'videos:$levelCode:$serieCode';
}
