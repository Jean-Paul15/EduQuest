import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LearningScope {
  const LearningScope({required this.countryId, required this.levelId});

  final String countryId;
  final String levelId;
}

class LearningScopeRepository {
  final _local = LocalJsonCache();

  Future<LearningScope?> current() async {
    final cached = await _fromLocal();
    if (!Env.hasSupabase) return cached;
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return cached;
    try {
      final row = await Supabase.instance.client
          .from('profiles')
          .select('country_id,education_level_id')
          .eq('id', uid)
          .maybeSingle();
      final countryId = row?['country_id']?.toString();
      final levelId = row?['education_level_id']?.toString();
      if (countryId == null || levelId == null) return cached;
      final out = LearningScope(countryId: countryId, levelId: levelId);
      await _local.writeList('learn:scope', [
        {'countryId': out.countryId, 'levelId': out.levelId},
      ]);
      return out;
    } catch (_) {
      return cached;
    }
  }

  Future<LearningScope?> _fromLocal() async {
    final rows = await _local.readList('learn:scope');
    if (rows == null || rows.isEmpty) return null;
    final r = rows.first;
    return LearningScope(
      countryId: '${r['countryId']}',
      levelId: '${r['levelId']}',
    );
  }
}
