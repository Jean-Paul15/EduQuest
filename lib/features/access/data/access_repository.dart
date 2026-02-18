import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccessState {
  final String tier;
  final DateTime? expiresAt;
  final bool hasAccess;

  const AccessState({
    required this.tier,
    required this.hasAccess,
    required this.expiresAt,
  });
}

class AccessRepository {
  final _local = LocalJsonCache();

  Future<AccessState> resolveAccess() async {
    final uid = Env.hasSupabase ? Supabase.instance.client.auth.currentUser?.id : null;
    final local = uid == null ? null : await _readLocal(uid);
    if (!Env.hasSupabase) {
      return local ?? const AccessState(tier: 'FREE', hasAccess: true, expiresAt: null);
    }
    final client = Supabase.instance.client;
    if (uid == null) {
      return const AccessState(tier: 'ANON', hasAccess: false, expiresAt: null);
    }
    try {
      final data = await client.rpc('resolve_access_scope');
      final tierRpc = (data as Map)['tier']?.toString() ?? 'UNKNOWN';
      final expiresRaw = data['expires_at']?.toString();
      final state = AccessState(
        tier: tierRpc,
        hasAccess: (data['has_access'] as bool?) ?? true,
        expiresAt: expiresRaw == null ? null : DateTime.tryParse(expiresRaw),
      );
      await _writeLocal(uid, state);
      return state;
    } catch (_) {
      final fromTickets = await _fromActiveTickets(uid);
      if (fromTickets != null) {
        await _writeLocal(uid, fromTickets);
        return fromTickets;
      }
      return local ?? const AccessState(tier: 'FREE', hasAccess: true, expiresAt: null);
    }
  }

  Future<AccessState?> _fromActiveTickets(String uid) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    List rows;
    try {
      rows = await Supabase.instance.client
          .from('ticket_codes')
          .select('expires_at,ticket_products(ticket_type)')
          .eq('activated_by', uid)
          .gt('expires_at', nowIso);
    } catch (_) {
      return null;
    }
    if (rows.isEmpty) return null;
    DateTime? fullExp;
    DateTime? halfExp;
    for (final r in rows) {
      final m = Map<String, dynamic>.from(r as Map);
      final exp = DateTime.tryParse('${m['expires_at'] ?? ''}');
      final tp =
          (m['ticket_products'] as Map?)?['ticket_type']?.toString() ?? '';
      if (exp == null) {
        continue;
      }
      if (tp == 'FULL') {
        fullExp = fullExp == null || exp.isAfter(fullExp) ? exp : fullExp;
      }
      if (tp == 'HALF') {
        halfExp = halfExp == null || exp.isAfter(halfExp) ? exp : halfExp;
      }
    }
    if (fullExp != null) {
      return AccessState(tier: 'FULL', hasAccess: true, expiresAt: fullExp);
    }
    if (halfExp != null) {
      return AccessState(tier: 'HALF', hasAccess: true, expiresAt: halfExp);
    }
    return const AccessState(tier: 'FREE', hasAccess: true, expiresAt: null);
  }

  Future<void> _writeLocal(String uid, AccessState s) async {
    await _local.writeList('access:state:$uid', [
      {
        'tier': s.tier,
        'hasAccess': s.hasAccess,
        'expiresAt': s.expiresAt?.toIso8601String(),
      },
    ]);
  }

  Future<AccessState?> _readLocal(String uid) async {
    final rows = await _local.readList('access:state:$uid');
    if (rows == null || rows.isEmpty) return null;
    final row = rows.first;
    return AccessState(
      tier: row['tier']?.toString() ?? 'FREE',
      hasAccess: row['hasAccess'] as bool? ?? true,
      expiresAt: DateTime.tryParse(row['expiresAt']?.toString() ?? ''),
    );
  }
}
