import 'package:eduquest/features/class_selection/data/class_selection_local_cache.dart';
import 'package:eduquest/features/class_selection/domain/level_option.dart';
import 'package:eduquest/features/class_selection/domain/series_option.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClassSelectionRepository {
  final _cache = ClassSelectionLocalCache();

  Future<Map<String, String?>> current() async {
    final local = await _cache.current();
    if (!Env.hasSupabase) return local;
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return local;
    try {
      final r = await Supabase.instance.client
          .from('profiles')
          .select('education_level_id,series_id')
          .eq('id', uid)
          .maybeSingle();
      final out = {
        'levelId': r?['education_level_id']?.toString(),
        'seriesId': r?['series_id']?.toString(),
      };
      await _cache.saveCurrent(out);
      return out;
    } catch (_) {
      return local;
    }
  }

  Future<List<LevelOption>> activeLevels() async {
    final local = await _cache.levels();
    if (!Env.hasSupabase) return local;
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return local;
    try {
      final p = await Supabase.instance.client
          .from('profiles')
          .select('country_id')
          .eq('id', uid)
          .maybeSingle();
      final rows = await Supabase.instance.client
          .from('education_levels')
          .select('id,code,label')
          .eq('country_id', p?['country_id'])
          .eq('is_active', true)
          .order('sort_order');
      final out = (rows as List)
          .map(
            (e) => LevelOption(
              id: '${e['id']}',
              code: '${e['code']}',
              label: '${e['label']}',
            ),
          )
          .toList();
      await _cache.saveLevels(out);
      return out;
    } catch (_) {
      return local;
    }
  }

  Future<List<SeriesOption>> activeSeries(String levelId) async {
    final local = await _cache.series(levelId);
    if (!Env.hasSupabase) return local;
    try {
      final rows = await Supabase.instance.client
          .from('series')
          .select('id,code,label')
          .eq('education_level_id', levelId)
          .eq('is_active', true)
          .order('code');
      final out = (rows as List)
          .map(
            (e) => SeriesOption(
              id: '${e['id']}',
              code: '${e['code']}',
              label: '${e['label']}',
            ),
          )
          .toList();
      await _cache.saveSeries(levelId, out);
      return out;
    } catch (_) {
      return local;
    }
  }

  Future<String> change(String levelId, String? seriesId) async {
    if (!Env.hasSupabase) return 'Supabase non configuré.';
    final res = await Supabase.instance.client.rpc(
      'change_student_level',
      params: {'p_level_id': levelId, 'p_series_id': seriesId},
    );
    return '${Map<String, dynamic>.from(res as Map)['message'] ?? 'Classe mise à jour.'}';
  }
}
