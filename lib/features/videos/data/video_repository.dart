import 'dart:async';
import 'package:eduquest/features/videos/data/video_scope.dart';
import 'package:eduquest/features/videos/domain/chapter_video.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VideoRepository {
  final _local = LocalJsonCache();

  Future<List<ChapterVideo>> byLevelAndSerie({
    required String levelCode,
    required String serieCode,
  }) async {
    final key = 'videos:$levelCode:$serieCode';
    final local = await _fromLocal(key);
    if (!Env.hasSupabase) return local;
    if (local.isNotEmpty) {
      unawaited(_refresh(levelCode: levelCode, serieCode: serieCode, key: key));
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
      final rows = await Supabase.instance.client
          .from('resources')
          .select('id,title,type,external_url,storage_path,access_scope')
          .inFilter('type', ['video', 'youtube'])
          .eq('published', true);
      final out = (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((e) {
            final scope = Map<String, dynamic>.from(
              (e['access_scope'] as Map?) ?? {},
            );
            return VideoScope.isVisible(
              scope: scope,
              levelCode: levelCode,
              serieCode: serieCode,
            );
          })
          .map((e) {
            final scope = Map<String, dynamic>.from(
              (e['access_scope'] as Map?) ?? {},
            );
            final url = '${e['external_url'] ?? e['storage_path'] ?? ''}';
            return ChapterVideo(
              id: '${e['id']}',
              chapter: '${scope['chapter'] ?? 'Chapitre'}',
              title: '${e['title']}',
              url: url,
              sharedAcrossLevels: VideoScope.isShared(scope),
            );
          })
          .where((v) => v.url.isNotEmpty)
          .toList();
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
}
