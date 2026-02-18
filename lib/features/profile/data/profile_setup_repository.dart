import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSetupState {
  const ProfileSetupState({
    required this.fullName,
    required this.levelId,
    required this.seriesId,
    required this.countryCode,
    required this.whatsappPhone,
    required this.complete,
  });
  final String fullName;
  final String? levelId;
  final String? seriesId;
  final String countryCode;
  final String whatsappPhone;
  final bool complete;
}

class ProfileSetupRepository {
  final _auth = AuthRepository();
  final _local = LocalJsonCache();

  Future<ProfileSetupState> load() async {
    if (!Env.hasSupabase || _auth.currentUser == null) {
      return const ProfileSetupState(
        fullName: '',
        levelId: null,
        seriesId: null,
        countryCode: 'TG',
        whatsappPhone: '',
        complete: false,
      );
    }
    final uid = _auth.currentUser!.id;
    try {
      await _ensureProfileRow();
      final row = await Supabase.instance.client
          .from('profiles')
          .select(
            'full_name,education_level_id,series_id,whatsapp_phone,country_id',
          )
          .eq('id', uid)
          .maybeSingle();
      final fullName = row?['full_name']?.toString().trim() ?? '';
      final levelId = row?['education_level_id']?.toString();
      final seriesId = row?['series_id']?.toString();
      final phone = row?['whatsapp_phone']?.toString().trim() ?? '';
      final countryCode = await _loadCountryCode(row?['country_id']) ?? 'TG';
      final complete =
          fullName.isNotEmpty &&
          levelId != null &&
          seriesId != null &&
          phone.isNotEmpty;
      final out = ProfileSetupState(
        fullName: fullName,
        levelId: levelId,
        seriesId: seriesId,
        countryCode: countryCode,
        whatsappPhone: phone,
        complete: complete,
      );
      await _writeLocal(uid, out);
      return out;
    } catch (_) {
      final cached = await _readLocal(uid);
      if (cached != null) return cached;
      return const ProfileSetupState(
        fullName: '',
        levelId: null,
        seriesId: null,
        countryCode: 'TG',
        whatsappPhone: '',
        complete: false,
      );
    }
  }

  Future<void> saveFullName(String name) async {
    final uid = _auth.currentUser?.id;
    if (!Env.hasSupabase || uid == null) return;
    try {
      await _ensureProfileRow();
      await Supabase.instance.client
          .from('profiles')
          .update({'full_name': name.trim()})
          .eq('id', uid);
    } catch (_) {}
    final cached = await _readLocal(uid);
    if (cached != null) {
      await _writeLocal(
        uid,
        ProfileSetupState(
          fullName: name.trim(),
          levelId: cached.levelId,
          seriesId: cached.seriesId,
          countryCode: cached.countryCode,
          whatsappPhone: cached.whatsappPhone,
          complete:
              name.trim().isNotEmpty &&
              cached.levelId != null &&
              cached.seriesId != null &&
              cached.whatsappPhone.trim().isNotEmpty,
        ),
      );
    }
  }

  Future<void> saveWhatsappPhone(String phone) async {
    final uid = _auth.currentUser?.id;
    if (!Env.hasSupabase || uid == null) return;
    try {
      await _ensureProfileRow();
      await Supabase.instance.client
          .from('profiles')
          .update({'whatsapp_phone': phone.trim()})
          .eq('id', uid);
    } catch (_) {}
    final cached = await _readLocal(uid);
    if (cached != null) {
      final v = phone.trim();
      await _writeLocal(
        uid,
        ProfileSetupState(
          fullName: cached.fullName,
          levelId: cached.levelId,
          seriesId: cached.seriesId,
          countryCode: cached.countryCode,
          whatsappPhone: v,
          complete:
              cached.fullName.isNotEmpty &&
              cached.levelId != null &&
              cached.seriesId != null &&
              v.isNotEmpty,
        ),
      );
    }
  }

  Future<String?> _loadCountryCode(dynamic id) async {
    if (id == null) return null;
    final row = await Supabase.instance.client
        .from('countries')
        .select('code')
        .eq('id', id)
        .maybeSingle();
    return row?['code']?.toString();
  }

  Future<void> _ensureProfileRow() async {
    final uid = _auth.currentUser?.id;
    if (uid == null) return;
    final p = await Supabase.instance.client
        .from('profiles')
        .select('id')
        .eq('id', uid)
        .maybeSingle();
    if (p != null) return;
    final tg = await Supabase.instance.client
        .from('countries')
        .select('id')
        .eq('code', 'TG')
        .maybeSingle();
    await Supabase.instance.client.from('profiles').insert({
      'id': uid,
      'role': 'student',
      'country_id': tg?['id'],
    });
  }

  Future<void> _writeLocal(String uid, ProfileSetupState s) async {
    await _local.writeList('profile:setup:$uid', [
      {
        'full_name': s.fullName,
        'education_level_id': s.levelId,
        'series_id': s.seriesId,
        'country_code': s.countryCode,
        'whatsapp_phone': s.whatsappPhone,
        'complete': s.complete,
      },
    ]);
  }

  Future<ProfileSetupState?> _readLocal(String uid) async {
    final rows = await _local.readList('profile:setup:$uid');
    if (rows == null || rows.isEmpty) return null;
    final r = rows.first;
    final fullName = r['full_name']?.toString() ?? '';
    final levelId = r['education_level_id']?.toString();
    final seriesId = r['series_id']?.toString();
    final countryCode = r['country_code']?.toString() ?? 'TG';
    final phone = r['whatsapp_phone']?.toString() ?? '';
    final complete = r['complete'] == true;
    return ProfileSetupState(
      fullName: fullName,
      levelId: levelId,
      seriesId: seriesId,
      countryCode: countryCode,
      whatsappPhone: phone,
      complete: complete,
    );
  }
}
