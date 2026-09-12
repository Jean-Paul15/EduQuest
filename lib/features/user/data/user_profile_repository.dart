import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/user/domain/user_profile.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/validation/phone_validator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileRepository {
  final _local = LocalJsonCache();

  Future<UserProfile> load() async {
    final auth = AuthRepository();
    final email = auth.currentUser?.email?.trim() ?? '';
    final metaName =
        auth.currentUser?.userMetadata?['name']?.toString() ?? 'Étudiant';
    if (!Env.hasSupabase || auth.currentUser == null) {
      return await _fromLocal() ??
          UserProfile(
            displayName: metaName,
            email: email,
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
            'full_name,whatsapp_phone,country:countries(code),level:education_levels(code),serie:series(code)',
          )
          .eq('id', uid)
          .maybeSingle();
      final fullName = row?['full_name']?.toString().trim();
      final out = UserProfile(
        displayName: (fullName == null || fullName.isEmpty)
            ? metaName
            : fullName,
        email: email,
        countryCode: _nestedCode(row, 'country') ?? 'TG',
        levelCode: _nestedCode(row, 'level') ?? 'Terminale',
        serieCode: _nestedCode(row, 'serie') ?? 'D',
        whatsappPhone: row?['whatsapp_phone']?.toString(),
      );
      await _local.writeList('user:profile', [
        {
          'displayName': out.displayName,
          'email': out.email,
          'countryCode': out.countryCode,
          'levelCode': out.levelCode,
          'serieCode': out.serieCode,
          'whatsappPhone': out.whatsappPhone,
        },
      ]);
      return out;
    } catch (_) {
      return await _fromLocal() ??
          UserProfile(
            displayName: metaName,
            email: email,
            countryCode: 'TG',
            levelCode: 'Terminale',
            serieCode: 'D',
          );
    }
  }

  String? _nestedCode(Map<String, dynamic>? row, String key) =>
      (row?[key] as Map?)?['code']?.toString();

  Future<UserProfile?> _fromLocal() async {
    final rows = await _local.readList('user:profile');
    if (rows == null || rows.isEmpty) return null;
    final r = rows.first;
    return UserProfile(
      displayName: '${r['displayName']}',
      email: '${r['email'] ?? ''}',
      countryCode: '${r['countryCode']}',
      levelCode: '${r['levelCode']}',
      serieCode: '${r['serieCode']}',
      whatsappPhone: r['whatsappPhone']?.toString(),
    );
  }

  Future<bool> saveWhatsappPhone(String phone) async {
    final auth = AuthRepository();
    if (!Env.hasSupabase || auth.currentUser == null) return false;
    final uid = auth.currentUser!.id;
    final out = normalizePhone(phone).replaceAll('+', '');
    await Supabase.instance.client
        .from('profiles')
        .update({'whatsapp_phone': out.isEmpty ? null : out})
        .eq('id', uid);
    final cached = await _fromLocal();
    if (cached != null) {
      await _local.writeList('user:profile', [
        {
          'displayName': cached.displayName,
          'email': cached.email,
          'countryCode': cached.countryCode,
          'levelCode': cached.levelCode,
          'serieCode': cached.serieCode,
          'whatsappPhone': out.isEmpty ? null : out,
        },
      ]);
    }
    return true;
  }
}
