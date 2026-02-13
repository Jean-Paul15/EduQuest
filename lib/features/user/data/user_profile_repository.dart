import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/user/domain/user_profile.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileRepository {
  final _local = LocalJsonCache();

  Future<UserProfile> load() async {
    final auth = AuthRepository();
    final metaName =
        auth.currentUser?.userMetadata?['name']?.toString() ?? 'Étudiant';
    if (!Env.hasSupabase || auth.currentUser == null) {
      return await _fromLocal() ??
          UserProfile(
            displayName: metaName,
            countryCode: 'TG',
            levelCode: 'Terminale',
            serieCode: 'D',
          );
    }
    final uid = auth.currentUser!.id;
    try {
      final row = await Supabase.instance.client
          .from('profiles')
          .select(
            'full_name,school_name,country_id,education_level_id,series_id',
          )
          .eq('id', uid)
          .maybeSingle();
      final country = await _loadCode('countries', row?['country_id']);
      final level = await _loadCode(
        'education_levels',
        row?['education_level_id'],
      );
      final serie = await _loadCode('series', row?['series_id']);
      final fullName = row?['full_name']?.toString().trim();
      final out = UserProfile(
        displayName: (fullName == null || fullName.isEmpty)
            ? metaName
            : fullName,
        countryCode: country ?? 'TG',
        levelCode: level ?? 'Terminale',
        serieCode: serie ?? 'D',
      );
      await _local.writeList('user:profile', [
        {
          'displayName': out.displayName,
          'countryCode': out.countryCode,
          'levelCode': out.levelCode,
          'serieCode': out.serieCode,
        },
      ]);
      return out;
    } catch (_) {
      return await _fromLocal() ??
          UserProfile(
            displayName: metaName,
            countryCode: 'TG',
            levelCode: 'Terminale',
            serieCode: 'D',
          );
    }
  }

  Future<String?> _loadCode(String table, dynamic id) async {
    if (id == null) return null;
    final row = await Supabase.instance.client
        .from(table)
        .select('code')
        .eq('id', id)
        .maybeSingle();
    return row?['code']?.toString();
  }

  Future<UserProfile?> _fromLocal() async {
    final rows = await _local.readList('user:profile');
    if (rows == null || rows.isEmpty) return null;
    final r = rows.first;
    return UserProfile(
      displayName: '${r['displayName']}',
      countryCode: '${r['countryCode']}',
      levelCode: '${r['levelCode']}',
      serieCode: '${r['serieCode']}',
    );
  }
}
