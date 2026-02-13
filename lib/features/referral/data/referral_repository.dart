import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReferralRepository {
  final _local = LocalJsonCache();

  Future<String> myCode() async {
    if (!Env.hasSupabase) return await _fromLocalCode() ?? 'DEMO0000';
    try {
      final code = await Supabase.instance.client.rpc('ensure_referral_code');
      final out = (code ?? '').toString().trim();
      if (out.isNotEmpty) {
        await _local.writeList('referral:mine', [
          {'code': out},
        ]);
      }
      return out;
    } catch (_) {
      return await _fromLocalCode() ?? '';
    }
  }

  Future<int> invitedCount() async {
    if (!Env.hasSupabase) return await _fromLocalCount() ?? 0;
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return await _fromLocalCount() ?? 0;
    try {
      final rows = await Supabase.instance.client
          .from('referral_uses')
          .select('id')
          .eq('referrer_profile_id', uid);
      final c = (rows as List).length;
      await _local.writeList('referral:count', [
        {'count': c},
      ]);
      return c;
    } catch (_) {
      return await _fromLocalCount() ?? 0;
    }
  }

  Future<String> applyCode(String code) async {
    if (!Env.hasSupabase) return 'Supabase non configuré.';
    final res = await Supabase.instance.client.rpc(
      'apply_referral_code',
      params: {'p_code': code},
    );
    return Map<String, dynamic>.from(res as Map)['message']?.toString() ??
        'Parrainage mis à jour.';
  }

  Future<String?> _fromLocalCode() async {
    final rows = await _local.readList('referral:mine');
    if (rows == null || rows.isEmpty) return null;
    return rows.first['code']?.toString();
  }

  Future<int?> _fromLocalCount() async {
    final rows = await _local.readList('referral:count');
    if (rows == null || rows.isEmpty) return null;
    return rows.first['count'] as int?;
  }
}
