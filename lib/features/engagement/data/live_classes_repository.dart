import 'dart:async';
import 'package:eduquest/features/engagement/domain/live_class_item.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LiveClassesRepository {
  final _local = LocalJsonCache();
  static const _key = 'hub:lives';
  static List<LiveClassItem>? _mem;

  static void clearMemory() {
    _mem = null;
  }

  Future<List<LiveClassItem>> list({bool forceRefresh = false}) async {
    if (forceRefresh && Env.hasSupabase) {
      final fresh = await _refresh();
      if (fresh != null) return fresh;
    }
    final mem = _mem;
    if (mem != null) {
      if (Env.hasSupabase) {
        unawaited(_refresh());
      }
      return mem;
    }
    final local = await _fromLocal();
    if (local.isNotEmpty) _mem = local;
    if (!Env.hasSupabase) return local;
    if (local.isNotEmpty) {
      unawaited(_refresh());
      return local;
    }
    final remote = await _refresh();
    return remote ?? local;
  }

  Future<List<LiveClassItem>?> _refresh() async {
    try {
      final rows = await Supabase.instance.client
          .from('live_classes')
          .select('id,title,starts_at,ends_at,zoom_link')
          .eq('is_visible', true)
          .gte('ends_at', DateTime.now().toUtc().toIso8601String())
          .order('starts_at');
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
      _mem = out;
      await _local.writeList(
        _key,
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

  Future<List<LiveClassItem>> _fromLocal() async {
    final rows = await _local.readList(_key);
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
