import 'package:eduquest/shared/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VideoFilterRepository {
  Future<String?> _countryId() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await Supabase.instance.client.from('profiles').select('country_id').eq('id', uid).maybeSingle();
    return row?['country_id']?.toString();
  }

  Future<List<String>> levels() async {
    if (!Env.hasSupabase) return const ['Seconde', 'Première', 'Terminale'];
    final cid = await _countryId();
    if (cid == null) return const ['Seconde', 'Première', 'Terminale'];
    final rows = await Supabase.instance.client
        .from('education_levels')
        .select('code')
        .eq('country_id', cid)
        .eq('is_active', true)
        .order('sort_order');
    final values = (rows as List).map((e) => '${e['code']}').where((e) => e.isNotEmpty).toList();
    return values.isEmpty ? const ['Seconde', 'Première', 'Terminale'] : values;
  }

  Future<List<String>> series(String levelCode) async {
    if (!Env.hasSupabase) return const ['A', 'C', 'D'];
    final cid = await _countryId();
    if (cid == null) return const ['A', 'C', 'D'];
    final level = await Supabase.instance.client
        .from('education_levels')
        .select('id')
        .eq('country_id', cid)
        .eq('code', levelCode)
        .eq('is_active', true)
        .maybeSingle();
    if (level == null) return const ['A', 'C', 'D'];
    final rows = await Supabase.instance.client
        .from('series')
        .select('code')
        .eq('education_level_id', level['id'])
        .eq('is_active', true)
        .order('code');
    final values = (rows as List).map((e) => '${e['code']}').where((e) => e.isNotEmpty).toList();
    return values.isEmpty ? const ['A', 'C', 'D'] : values;
  }
}
