import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReferralProgressItem {
  const ReferralProgressItem({
    required this.name,
    required this.status,
    required this.qualified,
  });

  final String name;
  final String status;
  final bool qualified;

  String get statusLabel => switch (status) {
    'reward_granted' => 'Récompense versée',
    'referred_ticket_activated' => 'Ticket activé',
    'referred_active_7d' => 'Actif depuis 7 jours',
    'referred_profile_completed' => 'Profil complété',
    _ => 'Compte créé',
  };
}

class ReferralSnapshot {
  const ReferralSnapshot({
    required this.invitedCount,
    required this.qualifiedCount,
    required this.items,
  });

  final int invitedCount;
  final int qualifiedCount;
  final List<ReferralProgressItem> items;
}

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

  Future<int> qualifiedCount() async {
    if (!Env.hasSupabase) return await _fromLocalQualifiedCount() ?? 0;
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return await _fromLocalQualifiedCount() ?? 0;
    try {
      final out = await Supabase.instance.client.rpc(
        'referral_qualified_count',
        params: {'p_referrer': uid},
      );
      final value = _toInt(out);
      await _local.writeList('referral:qualified', [
        {'count': value},
      ]);
      return value;
    } catch (_) {
      return await _fromLocalQualifiedCount() ?? 0;
    }
  }

  Future<ReferralSnapshot> loadProgress() async {
    if (!Env.hasSupabase) {
      return ReferralSnapshot(
        invitedCount: await _fromLocalCount() ?? 0,
        qualifiedCount: await _fromLocalQualifiedCount() ?? 0,
        items: const [],
      );
    }
    try {
      final rows = await Supabase.instance.client.rpc('list_referral_progress');
      final items = (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map(
            (row) => ReferralProgressItem(
              name: row['referred_name']?.toString() ?? 'Compte invité',
              status: row['status']?.toString() ?? 'referred_account_created',
              qualified: row['qualified'] == true,
            ),
          )
          .toList(growable: false);
      return ReferralSnapshot(
        invitedCount: items.length,
        qualifiedCount: items.where((item) => item.qualified).length,
        items: items,
      );
    } catch (_) {
      return ReferralSnapshot(
        invitedCount: await invitedCount(),
        qualifiedCount: await qualifiedCount(),
        items: const [],
      );
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

  Future<int?> _fromLocalQualifiedCount() async {
    final rows = await _local.readList('referral:qualified');
    if (rows == null || rows.isEmpty) return null;
    return rows.first['count'] as int?;
  }

  int _toInt(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? 0;
    if (raw is Map) {
      final first = raw.values.isEmpty ? null : raw.values.first;
      return _toInt(first);
    }
    return 0;
  }
}
