import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSetupState {
  const ProfileSetupState({
    required this.fullName,
    required this.levelId,
    required this.seriesId,
    required this.complete,
  });
  final String fullName;
  final String? levelId;
  final String? seriesId;
  final bool complete;
}

class ProfileSetupRepository {
  final _auth = AuthRepository();

  Future<ProfileSetupState> load() async {
    if (!Env.hasSupabase || _auth.currentUser == null) return const ProfileSetupState(fullName: '', levelId: null, seriesId: null, complete: false);
    await _ensureProfileRow();
    final row = await Supabase.instance.client.from('profiles').select('full_name,education_level_id,series_id').eq('id', _auth.currentUser!.id).maybeSingle();
    final fullName = row?['full_name']?.toString().trim() ?? '';
    final levelId = row?['education_level_id']?.toString();
    final seriesId = row?['series_id']?.toString();
    final complete = fullName.isNotEmpty && levelId != null && seriesId != null;
    return ProfileSetupState(fullName: fullName, levelId: levelId, seriesId: seriesId, complete: complete);
  }

  Future<void> saveFullName(String name) async {
    final uid = _auth.currentUser?.id;
    if (!Env.hasSupabase || uid == null) return;
    await _ensureProfileRow();
    await Supabase.instance.client.from('profiles').update({'full_name': name.trim()}).eq('id', uid);
  }

  Future<void> _ensureProfileRow() async {
    final uid = _auth.currentUser?.id;
    if (uid == null) return;
    final p = await Supabase.instance.client.from('profiles').select('id').eq('id', uid).maybeSingle();
    if (p != null) return;
    final tg = await Supabase.instance.client.from('countries').select('id').eq('code', 'TG').maybeSingle();
    await Supabase.instance.client.from('profiles').insert({'id': uid, 'role': 'student', 'country_id': tg?['id']});
  }

}
