import 'dart:async';
import 'package:eduquest/features/access/domain/access_repository_interface.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/core/result.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccessState {
  final String tier;
  final DateTime? expiresAt;
  final bool hasAccess;
  final String source;
  final String freeOfferCode;
  final Map<String, dynamic> scope;

  const AccessState({
    required this.tier,
    required this.hasAccess,
    required this.expiresAt,
    this.source = 'fallback',
    this.freeOfferCode = 'FREE_LIGHT',
    this.scope = const {},
  });

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now().toUtc());
  bool get isTrialFull => tier == 'TRIAL_FULL';
  bool get isFullLike =>
      tier == 'FULL' || tier == 'TRIAL_FULL' || tier == 'CAMPAIGN_FREE';
  bool get isHalfLike => isFullLike || tier == 'HALF';
  bool get isFreeLight => tier == 'FREE_LIGHT' || tier == 'FREE';

  String get displayTier => switch (tier) {
    'TRIAL_FULL' => 'Essai gratuit 14 jours',
    'FREE_LIGHT' => 'Apprendre léger',
    'CAMPAIGN_FREE' => 'Accès campagne',
    'FULL' => 'Accès complet',
    'HALF' => 'Accès standard',
    'ADMIN' => 'Administration',
    'ANON' => 'Visiteur',
    _ => tier,
  };

  bool canConsume(String contentType) {
    if (!hasAccess || isExpired) return false;
    if (contentType == 'free') return true;
    if (isFullLike) return true;
    if (tier == 'HALF') return contentType != 'premium';
    return false;
  }
}

class AccessRepository implements AccessRepositoryInterface {
  final _local = LocalJsonCache();
  final _controller = StreamController<AccessState>.broadcast();
  AccessState _last = const AccessState(
    tier: 'FREE_LIGHT',
    hasAccess: true,
    expiresAt: null,
  );

  Stream<AccessState> get accessStream => _controller.stream;
  AccessState get lastKnownAccess => _last;

  @override
  Future<Result<AccessState>> resolveAccess() async {
    final uid =
        Env.hasSupabase ? Supabase.instance.client.auth.currentUser?.id : null;
    final local = uid == null ? null : await _readLocal(uid);
    if (!Env.hasSupabase) {
      final s = local ??
          const AccessState(tier: 'FREE_LIGHT', hasAccess: true, expiresAt: null);
      _push(s);
      return success(s);
    }
    final client = Supabase.instance.client;
    if (uid == null) {
      const s = AccessState(tier: 'ANON', hasAccess: false, expiresAt: null);
      _push(s);
      return success(s);
    }
    try {
      final data = await client.rpc('resolve_access_scope');
      final tierRpc = (data as Map)['tier']?.toString() ?? 'UNKNOWN';
      final expiresRaw = data['expires_at']?.toString();
      final state = AccessState(
        tier: tierRpc,
        hasAccess: (data['has_access'] as bool?) ?? true,
        expiresAt: expiresRaw == null ? null : DateTime.tryParse(expiresRaw),
        source: data['source']?.toString() ?? 'runtime',
        freeOfferCode: data['free_offer_code']?.toString() ?? 'FREE_LIGHT',
        scope: Map<String, dynamic>.from(
          (data['scope'] as Map?) ?? const <String, dynamic>{},
        ),
      );
      await _writeLocal(uid, state);
      _push(state);
      return success(state);
    } catch (_) {
      final fromTickets = await _fromActiveTickets(uid);
      if (fromTickets != null) {
        await _writeLocal(uid, fromTickets);
        _push(fromTickets);
        return success(fromTickets);
      }
      final s = local ??
          const AccessState(tier: 'FREE_LIGHT', hasAccess: true, expiresAt: null);
      _push(s);
      return success(s);
    }
  }

  @override
  Future<Result<bool>> hasAccess(String contentType) async {
    final result = await resolveAccess();
    final state = result.dataOrNull;
    return success(state?.canConsume(contentType) == true);
  }

  void refresh() {
    unawaited(resolveAccess());
  }

  void dispose() {
    _controller.close();
  }

  void _push(AccessState s) {
    _last = s;
    _controller.add(s);
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
      return const AccessState(
        tier: 'FULL',
        hasAccess: true,
        expiresAt: null,
        source: 'ticket_fallback',
      ).copyWith(expiresAt: fullExp);
    }
    if (halfExp != null) {
      return const AccessState(
        tier: 'HALF',
        hasAccess: true,
        expiresAt: null,
        source: 'ticket_fallback',
      ).copyWith(expiresAt: halfExp);
    }
    return const AccessState(tier: 'FREE_LIGHT', hasAccess: true, expiresAt: null);
  }

  Future<void> _writeLocal(String uid, AccessState s) async {
    await _local.writeList('access:state:$uid', [
      {
        'tier': s.tier,
        'hasAccess': s.hasAccess,
        'expiresAt': s.expiresAt?.toIso8601String(),
        'source': s.source,
        'freeOfferCode': s.freeOfferCode,
        'scope': s.scope,
      },
    ]);
  }

  Future<AccessState?> _readLocal(String uid) async {
    final rows = await _local.readList('access:state:$uid');
    if (rows == null || rows.isEmpty) return null;
    final row = rows.first;
    return AccessState(
      tier: row['tier']?.toString() ?? 'FREE_LIGHT',
      hasAccess: row['hasAccess'] as bool? ?? true,
      expiresAt: DateTime.tryParse(row['expiresAt']?.toString() ?? ''),
      source: row['source']?.toString() ?? 'local_cache',
      freeOfferCode: row['freeOfferCode']?.toString() ?? 'FREE_LIGHT',
      scope: Map<String, dynamic>.from(
        (row['scope'] as Map?) ?? const <String, dynamic>{},
      ),
    );
  }
}

extension on AccessState {
  AccessState copyWith({
    String? tier,
    bool? hasAccess,
    DateTime? expiresAt,
    String? source,
    String? freeOfferCode,
    Map<String, dynamic>? scope,
  }) {
    return AccessState(
      tier: tier ?? this.tier,
      hasAccess: hasAccess ?? this.hasAccess,
      expiresAt: expiresAt ?? this.expiresAt,
      source: source ?? this.source,
      freeOfferCode: freeOfferCode ?? this.freeOfferCode,
      scope: scope ?? this.scope,
    );
  }
}
