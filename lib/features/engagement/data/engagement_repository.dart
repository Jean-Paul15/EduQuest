import 'dart:async';
import 'package:eduquest/features/engagement/domain/engagement_detail.dart';
import 'package:eduquest/features/engagement/domain/engagement_item.dart';
import 'package:eduquest/features/engagement/domain/event_pass.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eduquest/shared/realtime/cache_signal.dart';

class EngagementRepository {
  final _local = LocalJsonCache();
  static final Map<String, List<EngagementItem>> _listMem = {};
  static final Map<String, EngagementDetail> _detailMem = {};


  static void clearMemory() {
    _listMem.clear();
    _detailMem.clear();
  }

  /// Purge ciblee RAM pour l'invalidation temps reel.
  static void evictKeys(CacheTargets t) {
    for (final k in t.exact) {
      _listMem.remove(k);
    }
    for (final p in t.prefixes) {
      _listMem.removeWhere((k, _) => k.startsWith(p));
    }
  }

  static void clearListMemory(String key) {
    _listMem.remove(key);
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
    const select = 'id,title,starts_at,created_at,venue,meeting_url';
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
      return mem;
    }
    final local = await _fromLocal(key);
    if (local.isNotEmpty) _listMem[key] = local;
    if (!Env.hasSupabase) return local;
    if (local.isNotEmpty) {
      return local;
    }
    return (await _refreshSurveys(key)) ?? local;
  }

  Future<EngagementDetail> contestDetail(
    String id, {
    bool forceRefresh = false,
  }) async => _detail(
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
    forceRefresh: forceRefresh,
  );
  Future<EngagementDetail> eventDetail(
    String id, {
    bool forceRefresh = false,
  }) async => _detail(
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
    forceRefresh: forceRefresh,
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

  Future<Map<String, dynamic>> cancelContest(String id) async {
    if (!Env.hasSupabase) {
      return {'success': false, 'message': 'Supabase non configuré.'};
    }
    try {
      final res = await Supabase.instance.client.rpc(
        'cancel_contest_registration',
        params: {'p_contest_id': id},
      );
      return Map<String, dynamic>.from(res as Map);
    } catch (_) {
      return {
        'success': false,
        'message': 'Impossible d’exécuter l’opération pour le moment.',
      };
    }
  }

  Future<Map<String, dynamic>?> myContestEntry(
    String contestId, {
    bool forceRefresh = false,
  }) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return null;
    final key = 'contest:entry:$uid:$contestId';
    final local = await _fromLocalSingle(key);
    if (forceRefresh && Env.hasSupabase) {
      return await _refreshContestEntry(
            key: key,
            uid: uid,
            contestId: contestId,
          ) ??
          local;
    }
    if (local != null) return local;
    if (!Env.hasSupabase) return local;
    return await _refreshContestEntry(
          key: key,
          uid: uid,
          contestId: contestId,
        ) ??
        local;
  }

  Future<Map<String, dynamic>?> _refreshContestEntry({
    required String key,
    required String uid,
    required String contestId,
  }) async {
    try {
      final row = await Supabase.instance.client
          .from('contest_entries')
          .select('status,attendance_fee,qr_code')
          .eq('contest_id', contestId)
          .eq('profile_id', uid)
          .maybeSingle();
      final out = row == null ? null : Map<String, dynamic>.from(row);
      await _writeSingle(key, out);
      return out;
    } catch (_) {
      for (final cols in const [
        'attendance_fee,qr_code',
        'attendance_fee',
        'id',
      ]) {
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
          out['status'] = hasQr
              ? 'applied'
              : (fee > 0 ? 'pending_payment' : 'applied');
          await _writeSingle(key, out);
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

  Future<List<EventPass>> myEventPasses(
    String eventId, {
    bool forceRefresh = false,
  }) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return const [];
    final key = 'event:passes:$uid:$eventId';
    final local = await _fromLocalPasses(key);
    if (forceRefresh && Env.hasSupabase) {
      return await _refreshEventPasses(key: key, uid: uid, eventId: eventId) ??
          local;
    }
    if (local.isNotEmpty) return local;
    if (!Env.hasSupabase) return local;
    return await _refreshEventPasses(key: key, uid: uid, eventId: eventId) ??
        local;
  }

  Future<List<EventPass>?> _refreshEventPasses({
    required String key,
    required String uid,
    required String eventId,
  }) async {
    try {
      final rows = await Supabase.instance.client
          .from('event_registrations')
          .select('pass_code,created_at,attendance_fee,status')
          .eq('event_id', eventId)
          .eq('profile_id', uid)
          .order('created_at', ascending: false);
      final out = (rows as List)
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
      await _local.writeList(
        key,
        out
            .map(
              (e) => {
                'pass_code': e.passCode,
                'created_at': e.createdAt.toIso8601String(),
                'attendance_fee': e.attendanceFee,
                'status': e.status,
              },
            )
            .toList(),
      );
      return out;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> myEventRegistration(
    String eventId, {
    bool forceRefresh = false,
  }) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return null;
    final key = 'event:registration:$uid:$eventId';
    final local = await _fromLocalSingle(key);
    if (forceRefresh && Env.hasSupabase) {
      return await _refreshEventRegistration(
            key: key,
            uid: uid,
            eventId: eventId,
          ) ??
          local;
    }
    if (local != null) return local;
    if (!Env.hasSupabase) return local;
    return await _refreshEventRegistration(
          key: key,
          uid: uid,
          eventId: eventId,
        ) ??
        local;
  }

  Future<Map<String, dynamic>?> _refreshEventRegistration({
    required String key,
    required String uid,
    required String eventId,
  }) async {
    try {
      final row = await Supabase.instance.client
          .from('event_registrations')
          .select('status,attendance_fee,pass_code,created_at')
          .eq('event_id', eventId)
          .eq('profile_id', uid)
          .maybeSingle();
      final out = row == null ? null : Map<String, dynamic>.from(row);
      await _writeSingle(key, out);
      return out;
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
        out['status'] = hasPass
            ? 'applied'
            : (fee > 0 ? 'pending_payment' : 'applied');
        await _writeSingle(key, out);
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
      return mem;
    }
    final local = await _fromLocal(key);
    if (local.isNotEmpty) _listMem[key] = local;
    if (!Env.hasSupabase) return local;
    if (local.isNotEmpty) {
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
    String fallbackTitle, {
    bool forceRefresh = false,
  }) async {
    final memKey = '$table:$id';
    final local = await _fromLocalDetail(memKey);
    if (forceRefresh && Env.hasSupabase) {
      return await _refreshDetail(
            memKey: memKey,
            table: table,
            id: id,
            select: select,
            ok: ok,
          ) ??
          local ??
          EngagementDetail(
            id: id,
            title: fallbackTitle,
            description: 'Impossible de charger le détail actuellement.',
            requiredTicketType: null,
            startsAt: DateTime.now(),
          );
    }
    final mem = _detailMem[memKey];
    if (mem != null) return mem;
    if (local != null) {
      _detailMem[memKey] = local;
      if (Env.hasSupabase) {
        unawaited(
          _refreshDetail(
            memKey: memKey,
            table: table,
            id: id,
            select: select,
            ok: ok,
          ),
        );
      }
      return local;
    }
    if (!Env.hasSupabase) {
      return EngagementDetail(
        id: id,
        title: fallbackTitle,
        description: 'Impossible de charger le détail actuellement.',
        requiredTicketType: null,
        startsAt: DateTime.now(),
      );
    }
    try {
      return await _refreshDetail(
            memKey: memKey,
            table: table,
            id: id,
            select: select,
            ok: ok,
          ) ??
          EngagementDetail(
            id: id,
            title: fallbackTitle,
            description: 'Impossible de charger le détail actuellement.',
            requiredTicketType: null,
            startsAt: DateTime.now(),
          );
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

  Future<EngagementDetail?> _refreshDetail({
    required String memKey,
    required String table,
    required String id,
    required String select,
    required EngagementDetail Function(Map row) ok,
  }) async {
    try {
      final row = await Supabase.instance.client
          .from(table)
          .select(select)
          .eq('id', id)
          .eq('is_visible', true)
          .single();
      final value = ok(Map<String, dynamic>.from(row as Map));
      _detailMem[memKey] = value;
      await _writeSingle(_detailKey(memKey), _detailToMap(value));
      return value;
    } catch (_) {
      return null;
    }
  }

  Future<EngagementDetail?> _fromLocalDetail(String memKey) async {
    final row = await _fromLocalSingle(_detailKey(memKey));
    return row == null ? null : _detailFromMap(row);
  }

  String _detailKey(String memKey) => 'engagement:detail:$memKey';

  Future<Map<String, dynamic>?> _fromLocalSingle(String key) async {
    final rows = await _local.readList(key);
    if (rows == null || rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }

  Future<void> _writeSingle(String key, Map<String, dynamic>? value) async {
    if (value == null) return;
    await _local.writeList(key, [value]);
  }

  Future<List<EventPass>> _fromLocalPasses(String key) async {
    final rows = await _local.readList(key);
    if (rows == null) return const [];
    return rows
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
  }

  Map<String, dynamic> _detailToMap(EngagementDetail detail) => {
    'id': detail.id,
    'title': detail.title,
    'description': detail.description,
    'required_ticket_type': detail.requiredTicketType,
    'starts_at': detail.startsAt.toIso8601String(),
    'ends_at': detail.endsAt?.toIso8601String(),
    'venue': detail.venue,
    'external_url': detail.externalUrl,
    'meeting_url': detail.meetingUrl,
    'logo_url': detail.logoUrl,
    'is_in_person': detail.isInPerson,
    'location_lat': detail.locationLat,
    'location_lng': detail.locationLng,
    'pricing_mode': detail.pricingMode,
    'fee_full': detail.feeFull,
    'fee_half': detail.feeHalf,
    'fee_free': detail.feeFree,
    'fee_campaign_free': detail.feeCampaignFree,
    'free_for_full': detail.freeForFull,
    'require_whatsapp': detail.requireWhatsapp,
  };

  EngagementDetail _detailFromMap(Map<String, dynamic> row) => EngagementDetail(
    id: '${row['id']}',
    title: '${row['title']}',
    description: '${row['description'] ?? ''}',
    requiredTicketType: row['required_ticket_type']?.toString(),
    startsAt: DateTime.tryParse('${row['starts_at']}') ?? DateTime.now(),
    endsAt: DateTime.tryParse('${row['ends_at'] ?? ''}'),
    venue: row['venue']?.toString(),
    externalUrl: row['external_url']?.toString(),
    meetingUrl: row['meeting_url']?.toString(),
    logoUrl: row['logo_url']?.toString(),
    isInPerson: row['is_in_person'] as bool?,
    locationLat: (row['location_lat'] as num?)?.toDouble(),
    locationLng: (row['location_lng'] as num?)?.toDouble(),
    pricingMode: row['pricing_mode']?.toString(),
    feeFull: (row['fee_full'] as num?)?.toDouble(),
    feeHalf: (row['fee_half'] as num?)?.toDouble(),
    feeFree: (row['fee_free'] as num?)?.toDouble(),
    feeCampaignFree: (row['fee_campaign_free'] as num?)?.toDouble(),
    freeForFull: row['free_for_full'] as bool?,
    requireWhatsapp: row['require_whatsapp'] as bool?,
  );

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
