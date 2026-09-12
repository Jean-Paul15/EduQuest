import 'dart:async';
import 'package:eduquest/features/engagement/domain/live_class_item.dart';
import 'package:eduquest/features/learning/data/learning_scope_repository.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eduquest/shared/realtime/cache_signal.dart';

class LiveClassesRepository {
  final _scopeRepo = LearningScopeRepository();
  final _local = LocalJsonCache();
  static final Map<String, List<LiveClassItem>> _mem = {};


  static void clearMemory() {
    _mem.clear();
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

  Future<List<LiveClassItem>> list({bool forceRefresh = false}) async {
    final scope = await _scopeRepo.current();
    if (scope == null || !scope.hasSeries) return const [];
    final cacheKey = 'hub:lives:${scope.levelId}:${scope.seriesId}';
    if (forceRefresh && Env.hasSupabase) {
      final fresh = await _refresh(scope.levelId, scope.seriesId!, cacheKey);
      if (fresh != null) return fresh;
    }
    final mem = _mem[cacheKey];
    if (mem != null) {
      return mem;
    }
    final local = await _fromLocal(cacheKey);
    if (local.isNotEmpty) _mem[cacheKey] = local;
    if (!Env.hasSupabase) return local;
    if (local.isNotEmpty) {
      return local;
    }
    final remote = await _refresh(scope.levelId, scope.seriesId!, cacheKey);
    return remote ?? local;
  }

  Future<List<LiveClassItem>?> _refresh(
    String levelId,
    String seriesId,
    String cacheKey,
  ) async {
    try {
      final rows = await Supabase.instance.client.rpc(
        'list_live_classes',
        params: {'p_level_id': levelId, 'p_series_id': seriesId},
      );
      final out = (rows as List)
          .map(
            (e) => LiveClassItem(
              id: '${e['id']}',
              title: '${e['title']}',
              startsAt:
                  DateTime.tryParse('${e['starts_at']}') ?? DateTime.now(),
              endsAt: DateTime.tryParse('${e['ends_at']}') ?? DateTime.now(),
              zoomLink: '${e['zoom_link'] ?? ''}',
            ),
          )
          .where((e) => e.zoomLink.isNotEmpty)
          .toList();
      _mem[cacheKey] = out;
      await _local.writeList(
        cacheKey,
        out
            .map(
              (e) => {
                'id': e.id,
                'title': e.title,
                'startsAt': e.startsAt.toIso8601String(),
                'endsAt': e.endsAt.toIso8601String(),
                'zoomLink': e.zoomLink,
              },
            )
            .toList(),
      );
      return out;
    } catch (_) {
      return null;
    }
  }

  Future<List<LiveClassItem>> _fromLocal(String cacheKey) async {
    final rows = await _local.readList(cacheKey);
    if (rows == null) return const [];
    return rows
        .map(
          (e) => LiveClassItem(
            id: '${e['id']}',
            title: '${e['title']}',
            startsAt: DateTime.tryParse('${e['startsAt']}') ?? DateTime.now(),
            endsAt: DateTime.tryParse('${e['endsAt']}') ?? DateTime.now(),
            zoomLink: '${e['zoomLink'] ?? ''}',
          ),
        )
        .where((e) => e.zoomLink.isNotEmpty)
        .toList();
  }
}
