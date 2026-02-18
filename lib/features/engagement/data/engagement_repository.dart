import 'dart:async';
import 'package:eduquest/features/engagement/domain/engagement_detail.dart';
import 'package:eduquest/features/engagement/domain/engagement_item.dart';
import 'package:eduquest/features/engagement/domain/event_pass.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EngagementRepository {
  final _local = LocalJsonCache();
  static final Map<String, List<EngagementItem>> _listMem = {};
  static final Map<String, EngagementDetail> _detailMem = {};

  static void clearMemory() {
    _listMem.clear();
    _detailMem.clear();
  }

  Future<void> clearSurveysCache() async {
    _listMem.remove('hub:surveys');
    await _local.removeByPrefix('hub:surveys');
  }

  Future<List<EngagementItem>> listContests({bool forceRefresh = false}) async {
    const key = 'hub:contests';
    final table = 'contests';
    const select = 'id,title,starts_at,created_at,is_in_person,venue';
    EngagementItem map(Map e) => EngagementItem(
      id: '${e['id']}',
      title: '${e['title']}',
      subtitle: (e['is_in_person'] as bool? ?? false)
          ? 'Concours présentiel • ${e['venue'] ?? 'Lieu à confirmer'}'
          : 'Concours en ligne',
      startsAt: DateTime.tryParse('${e['starts_at']}') ?? DateTime.now(),
      requiredTicketType: null,
    );
    dynamic q(dynamic b) => b
        .eq('is_visible', true)
        .gte('ends_at', DateTime.now().toUtc().toIso8601String());
    if (forceRefresh && Env.hasSupabase) {
      final fresh = await _refresh(
        key: key,
        table: table,
        select: select,
        map: map,
        q: q,
      );
      if (fresh != null) return fresh;
    }
    return _list(key: key, table: table, select: select, map: map, q: q);
  }

  Future<List<EngagementItem>> listEvents({bool forceRefresh = false}) async {
    const key = 'hub:events';
    const table = 'events';
    const select =
        'id,title,starts_at,created_at,venue,meeting_url';
    EngagementItem map(Map e) {
      final venue = e['venue']?.toString() ?? '';
      final hasVenue = venue.trim().isNotEmpty;
      final hasMeeting = (e['meeting_url']?.toString().isNotEmpty ?? false);
      final subtitle = hasVenue && hasMeeting
          ? 'Hybride • $venue'
          : hasMeeting
          ? 'En ligne • Lien de réunion'
          : hasVenue
          ? 'Présentiel • $venue'
          : 'Lieu à confirmer';
      return EngagementItem(
        id: '${e['id']}',
        title: '${e['title']}',
        subtitle: subtitle,
        startsAt: DateTime.tryParse('${e['starts_at']}') ?? DateTime.now(),
        requiredTicketType: null,
      );
    }

    dynamic q(dynamic b) => b.eq('is_visible', true);
    if (forceRefresh && Env.hasSupabase) {
      final fresh = await _refresh(
        key: key,
        table: table,
        select: select,
        map: map,
        q: q,
      );
      if (fresh != null) return fresh;
    }
    return _list(key: key, table: table, select: select, map: map, q: q);
  }

  Future<List<EngagementItem>> listSurveys({bool forceRefresh = false}) async {
    const key = 'hub:surveys';
    if (forceRefresh && Env.hasSupabase) {
      final fresh = await _refreshSurveys(key);
      if (fresh != null) return fresh;
    }
    final mem = _listMem[key];
    if (mem != null) {
      if (Env.hasSupabase) unawaited(_refreshSurveys(key));
      return mem;
    }
    final local = await _fromLocal(key);
    if (local.isNotEmpty) _listMem[key] = local;
    if (!Env.hasSupabase) return local;
    if (local.isNotEmpty) {
      unawaited(_refreshSurveys(key));
      return local;
    }
    return (await _refreshSurveys(key)) ?? local;
  }

  Future<EngagementDetail> contestDetail(String id) async => _detail(
    'contests',
    id,
    '*',
    (r) => EngagementDetail(
      id: id,
      title: '${r['title']}',
      description: '${r['rules_md']}',
      requiredTicketType: r['required_ticket_type']?.toString(),
      startsAt: DateTime.tryParse('${r['starts_at']}') ?? DateTime.now(),
      endsAt: DateTime.tryParse('${r['ends_at']}'),
      isInPerson: r['is_in_person'] as bool? ?? false,
      venue: r['venue']?.toString(),
      externalUrl: r['external_checkout_url']?.toString(),
      logoUrl: r['logo_url']?.toString(),
      locationLat: (r['location_lat'] as num?)?.toDouble(),
      locationLng: (r['location_lng'] as num?)?.toDouble(),
      pricingMode: r['pricing_mode']?.toString(),
      feeFull: (r['fee_full'] as num?)?.toDouble(),
      feeHalf: (r['fee_half'] as num?)?.toDouble(),
      feeFree: (r['fee_free'] as num?)?.toDouble(),
      feeCampaignFree: (r['fee_campaign_free'] as num?)?.toDouble(),
      freeForFull: r['free_for_full'] as bool?,
      requireWhatsapp: r['require_whatsapp'] as bool?,
    ),
    'Concours indisponible',
  );
  Future<EngagementDetail> eventDetail(String id) async => _detail(
    'events',
    id,
    '*',
    (r) => EngagementDetail(
      id: id,
      title: '${r['title']}',
      description: 'Type: ${r['event_type']}',
      requiredTicketType: r['required_ticket_type']?.toString(),
      startsAt: DateTime.tryParse('${r['starts_at']}') ?? DateTime.now(),
      venue: r['venue']?.toString(),
      logoUrl: r['logo_url']?.toString(),
      meetingUrl: r['meeting_url']?.toString(),
      externalUrl: r['external_ticket_url']?.toString(),
      locationLat: (r['location_lat'] as num?)?.toDouble(),
      locationLng: (r['location_lng'] as num?)?.toDouble(),
      pricingMode: r['pricing_mode']?.toString(),
      feeFull: (r['fee_full'] as num?)?.toDouble(),
      feeHalf: (r['fee_half'] as num?)?.toDouble(),
      feeFree: (r['fee_free'] as num?)?.toDouble(),
      feeCampaignFree: (r['fee_campaign_free'] as num?)?.toDouble(),
      freeForFull: r['free_for_full'] as bool?,
    ),
    'Événement indisponible',
  );
  Future<Map<String, dynamic>> joinContest(String id) async {
    if (!Env.hasSupabase) {
      return {'success': false, 'message': 'Supabase non configuré.'};
    }
    try {
      final client = Supabase.instance.client;
      dynamic res;
      try {
        res = await client.rpc(
          'join_contest',
          params: {'p_contest_id': id, 'p_whatsapp': ''},
        );
      } catch (e) {
        final text = '$e'.toLowerCase();
        final missingFn =
            text.contains('42883') ||
            (text.contains('function') && text.contains('join_contest'));
        if (!missingFn) rethrow;
        res = await client.rpc('join_contest', params: {'p_contest_id': id});
      }
      return Map<String, dynamic>.from(res as Map);
    } catch (_) {
      return {
        'success': false,
        'message': 'Impossible d’exécuter l’opération pour le moment.',
      };
    }
  }

  Future<String> cancelContest(String id) async {
    if (!Env.hasSupabase) return 'Supabase non configuré.';
    try {
      final res = await Supabase.instance.client.rpc(
        'cancel_contest_application',
        params: {'p_contest_id': id},
      );
      return Map<String, dynamic>.from(res as Map)['message']?.toString() ??
          'Postulation annulée.';
    } catch (_) {
      return 'Impossible d’exécuter l’opération pour le moment.';
    }
  }

  Future<Map<String, dynamic>?> myContestEntry(String contestId) async {
    if (!Env.hasSupabase) return null;
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      final row = await Supabase.instance.client
          .from('contest_entries')
          .select('status,attendance_fee,qr_code')
          .eq('contest_id', contestId)
          .eq('profile_id', uid)
          .maybeSingle();
      return row == null ? null : Map<String, dynamic>.from(row);
    } catch (_) {
      for (final cols in const ['attendance_fee,qr_code', 'attendance_fee', 'id']) {
        try {
          final row = await Supabase.instance.client
              .from('contest_entries')
              .select(cols)
              .eq('contest_id', contestId)
              .eq('profile_id', uid)
              .maybeSingle();
          if (row == null) return null;
          final out = Map<String, dynamic>.from(row);
          final hasQr = (out['qr_code']?.toString().isNotEmpty ?? false);
          final fee = (out['attendance_fee'] as num?)?.toDouble() ?? 0;
          out['status'] =
              hasQr ? 'applied' : (fee > 0 ? 'pending_payment' : 'applied');
          return out;
        } catch (_) {}
      }
      return null;
    }
  }

  Future<Map<String, dynamic>> joinEvent(String id) async {
    if (!Env.hasSupabase) {
      return {'success': false, 'message': 'Supabase non configuré.'};
    }
    try {
      final res = await Supabase.instance.client.rpc(
        'join_event',
        params: {'p_event_id': id},
      );
      return Map<String, dynamic>.from(res as Map);
    } catch (_) {
      return {
        'success': false,
        'message': 'Impossible d’exécuter l’opération pour le moment.',
      };
    }
  }

  Future<List<EventPass>> myEventPasses(String eventId) async {
    if (!Env.hasSupabase) return const [];
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return const [];
    try {
      final rows = await Supabase.instance.client
          .from('event_registrations')
          .select('pass_code,created_at,attendance_fee,status')
          .eq('event_id', eventId)
          .eq('profile_id', uid)
          .order('created_at', ascending: false);
      return (rows as List)
          .map(
            (e) => EventPass(
              passCode: '${e['pass_code'] ?? ''}',
              createdAt:
                  DateTime.tryParse('${e['created_at']}') ?? DateTime.now(),
              attendanceFee: (e['attendance_fee'] as num?)?.toDouble(),
              status: e['status']?.toString(),
            ),
          )
          .where((e) => e.passCode.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<Map<String, dynamic>?> myEventRegistration(String eventId) async {
    if (!Env.hasSupabase) return null;
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      final row = await Supabase.instance.client
          .from('event_registrations')
          .select('status,attendance_fee,pass_code,created_at')
          .eq('event_id', eventId)
          .eq('profile_id', uid)
          .maybeSingle();
      return row == null ? null : Map<String, dynamic>.from(row);
    } catch (_) {
      try {
        final row = await Supabase.instance.client
            .from('event_registrations')
            .select('attendance_fee,pass_code,created_at')
            .eq('event_id', eventId)
            .eq('profile_id', uid)
            .maybeSingle();
        if (row == null) return null;
        final out = Map<String, dynamic>.from(row);
        final hasPass = (out['pass_code']?.toString().isNotEmpty ?? false);
        final fee = (out['attendance_fee'] as num?)?.toDouble() ?? 0;
        out['status'] =
            hasPass ? 'applied' : (fee > 0 ? 'pending_payment' : 'applied');
        return out;
      } catch (_) {
        return null;
      }
    }
  }

  Future<List<EngagementItem>> _list({
    required String key,
    required String table,
    required String select,
    required EngagementItem Function(Map e) map,
    required dynamic Function(dynamic b) q,
  }) async {
    final mem = _listMem[key];
    if (mem != null) {
      if (Env.hasSupabase) {
        unawaited(
          _refresh(key: key, table: table, select: select, map: map, q: q),
        );
      }
      return mem;
    }
    final local = await _fromLocal(key);
    if (local.isNotEmpty) _listMem[key] = local;
    if (!Env.hasSupabase) return local;
    if (local.isNotEmpty) {
      unawaited(
        _refresh(key: key, table: table, select: select, map: map, q: q),
      );
      return local;
    }
    final remote = await _refresh(
      key: key,
      table: table,
      select: select,
      map: map,
      q: q,
    );
    return remote ?? local;
  }

  Future<List<EngagementItem>?> _refresh({
    required String key,
    required String table,
    required String select,
    required EngagementItem Function(Map e) map,
    required dynamic Function(dynamic b) q,
  }) async {
    try {
      final rows = await q(Supabase.instance.client.from(table).select(select));
      final rawRows = (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final out = rawRows.map(map).toList();
      _listMem[key] = out;
      await _local.writeList(
        key,
        List.generate(out.length, (i) {
          final e = out[i];
          final raw = rawRows[i];
          return {
            'id': e.id,
            'title': e.title,
            'subtitle': e.subtitle,
            'startsAt': e.startsAt.toIso8601String(),
            'createdAt':
                raw['created_at']?.toString() ??
                raw['starts_at']?.toString() ??
                '',
            'requiredTicketType': e.requiredTicketType,
          };
        }),
      );
      return out;
    } catch (_) {
      return null;
    }
  }

  Future<List<EngagementItem>> _fromLocal(String key) async {
    final rows = await _local.readList(key);
    if (rows == null) return const [];
    return rows
        .map(
          (e) => EngagementItem(
            id: '${e['id']}',
            title: '${e['title']}',
            subtitle: '${e['subtitle']}',
            startsAt: DateTime.tryParse('${e['startsAt']}') ?? DateTime.now(),
            requiredTicketType: e['requiredTicketType']?.toString(),
          ),
        )
        .toList();
  }

  Future<EngagementDetail> _detail(
    String table,
    String id,
    String select,
    EngagementDetail Function(Map row) ok,
    String fallbackTitle,
  ) async {
    final memKey = '$table:$id';
    final mem = _detailMem[memKey];
    if (mem != null) return mem;
    try {
      final row = await Supabase.instance.client
          .from(table)
          .select(select)
          .eq('id', id)
          .eq('is_visible', true)
          .single();
      final value = ok(Map<String, dynamic>.from(row as Map));
      _detailMem[memKey] = value;
      return value;
    } catch (_) {
      return EngagementDetail(
        id: id,
        title: fallbackTitle,
        description: 'Impossible de charger le détail actuellement.',
        requiredTicketType: null,
        startsAt: DateTime.now(),
      );
    }
  }

  Future<List<EngagementItem>?> _refreshSurveys(String key) async {
    try {
      final s = Supabase.instance.client;
      final uid = s.auth.currentUser?.id;
      final rows = await s
          .from('surveys')
          .select('id,title,starts_at,created_at')
          .eq('is_visible', true)
          .gte('ends_at', DateTime.now().toUtc().toIso8601String());
      final raw = (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final ids = raw.map((e) => '${e['id']}').toList();
      final answered = <String>{};
      if (uid != null && ids.isNotEmpty) {
        final answers = await s
            .from('survey_answers')
            .select('survey_id')
            .eq('profile_id', uid)
            .inFilter('survey_id', ids);
        answered.addAll((answers as List).map((e) => '${e['survey_id']}'));
      }
      final visible = raw
          .where((e) => !answered.contains('${e['id']}'))
          .toList();
      final out = visible
          .map(
            (e) => EngagementItem(
              id: '${e['id']}',
              title: '${e['title']}',
              subtitle: 'Enquête hebdomadaire',
              startsAt:
                  DateTime.tryParse('${e['starts_at']}') ?? DateTime.now(),
            ),
          )
          .toList();
      _listMem[key] = out;
      await _local.writeList(
        key,
        List.generate(out.length, (i) {
          final e = out[i];
          final r = visible[i];
          return {
            'id': e.id,
            'title': e.title,
            'subtitle': e.subtitle,
            'startsAt': e.startsAt.toIso8601String(),
            'createdAt': r['created_at']?.toString() ?? '',
            'requiredTicketType': null,
          };
        }),
      );
      return out;
    } catch (_) {
      return null;
    }
  }
}
