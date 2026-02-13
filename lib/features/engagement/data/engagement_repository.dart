import 'dart:async';
import 'package:eduquest/features/engagement/domain/engagement_detail.dart';
import 'package:eduquest/features/engagement/domain/engagement_item.dart';
import 'package:eduquest/features/engagement/domain/event_pass.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/cache_policy.dart';
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

  Future<List<EngagementItem>> listContests() => _list(
    key: 'hub:contests',
    table: 'contests',
    select: 'id,title,starts_at,required_ticket_type,is_in_person,venue',
    map: (e) => EngagementItem(
      id: '${e['id']}',
      title: '${e['title']}',
      subtitle: (e['is_in_person'] as bool? ?? false)
          ? 'Concours présentiel • ${e['venue'] ?? 'Lieu à confirmer'}'
          : 'Concours en ligne',
      startsAt: DateTime.tryParse('${e['starts_at']}') ?? DateTime.now(),
      requiredTicketType: e['required_ticket_type']?.toString(),
    ),
    q: (b) => b
        .eq('is_visible', true)
        .gte('ends_at', DateTime.now().toUtc().toIso8601String()),
  );
  Future<List<EngagementItem>> listEvents() => _list(
    key: 'hub:events',
    table: 'events',
    select: 'id,title,starts_at,venue,required_ticket_type,external_ticket_url',
    map: (e) => EngagementItem(
      id: '${e['id']}',
      title: '${e['title']}',
      subtitle: (e['external_ticket_url']?.toString().isNotEmpty ?? false)
          ? 'Paiement sur site • ${e['venue'] ?? 'Lieu à confirmer'}'
          : '${e['venue'] ?? 'Lieu à confirmer'}',
      startsAt: DateTime.tryParse('${e['starts_at']}') ?? DateTime.now(),
      requiredTicketType: e['required_ticket_type']?.toString(),
    ),
    q: (b) => b.eq('is_visible', true),
  );
  Future<List<EngagementItem>> listSurveys() => _list(
    key: 'hub:surveys',
    table: 'surveys',
    select: 'id,title,starts_at',
    map: (e) => EngagementItem(
      id: '${e['id']}',
      title: '${e['title']}',
      subtitle: 'Enquête hebdomadaire',
      startsAt: DateTime.tryParse('${e['starts_at']}') ?? DateTime.now(),
    ),
    q: (b) => b
        .eq('is_visible', true)
        .gte('ends_at', DateTime.now().toUtc().toIso8601String()),
  );

  Future<EngagementDetail> contestDetail(String id) async => _detail(
    'contests',
    id,
    'id,title,rules_md,required_ticket_type,starts_at,ends_at,is_in_person,venue',
    (r) => EngagementDetail(
      id: id,
      title: '${r['title']}',
      description: '${r['rules_md']}',
      requiredTicketType: r['required_ticket_type']?.toString(),
      startsAt: DateTime.tryParse('${r['starts_at']}') ?? DateTime.now(),
      endsAt: DateTime.tryParse('${r['ends_at']}'),
      isInPerson: r['is_in_person'] as bool? ?? false,
      venue: r['venue']?.toString(),
    ),
    'Concours indisponible',
  );
  Future<EngagementDetail> eventDetail(String id) async => _detail(
    'events',
    id,
    'id,title,event_type,venue,required_ticket_type,starts_at,external_ticket_url',
    (r) => EngagementDetail(
      id: id,
      title: '${r['title']}',
      description: 'Type: ${r['event_type']}',
      requiredTicketType: r['required_ticket_type']?.toString(),
      startsAt: DateTime.tryParse('${r['starts_at']}') ?? DateTime.now(),
      venue: r['venue']?.toString(),
      externalUrl: r['external_ticket_url']?.toString(),
    ),
    'Événement indisponible',
  );
  Future<String> joinContest(String id) async =>
      _join('join_contest', 'p_contest_id', id);
  Future<String> joinEvent(String id) async =>
      _join('join_event', 'p_event_id', id);

  Future<List<EventPass>> myEventPasses(String eventId) async {
    if (!Env.hasSupabase) return const [];
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return const [];
    try {
      final rows = await Supabase.instance.client
          .from('event_registrations')
          .select('pass_code,created_at')
          .eq('event_id', eventId)
          .eq('profile_id', uid)
          .order('created_at', ascending: false);
      return (rows as List)
          .map(
            (e) => EventPass(
              passCode: '${e['pass_code'] ?? ''}',
              createdAt:
                  DateTime.tryParse('${e['created_at']}') ?? DateTime.now(),
            ),
          )
          .where((e) => e.passCode.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
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
      if (Env.hasSupabase && !await _local.isFresh(key, CachePolicy.hubLists)) {
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
      if (!await _local.isFresh(key, CachePolicy.hubLists)) {
        unawaited(
          _refresh(key: key, table: table, select: select, map: map, q: q),
        );
      }
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
      final out = (rows as List)
          .map((e) => map(Map<String, dynamic>.from(e as Map)))
          .toList();
      _listMem[key] = out;
      await _local.writeList(
        key,
        out
            .map(
              (e) => {
                'id': e.id,
                'title': e.title,
                'subtitle': e.subtitle,
                'startsAt': e.startsAt.toIso8601String(),
                'requiredTicketType': e.requiredTicketType,
              },
            )
            .toList(),
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

  Future<String> _join(String rpc, String param, String id) async {
    if (!Env.hasSupabase) return 'Supabase non configuré.';
    try {
      final res = await Supabase.instance.client.rpc(rpc, params: {param: id});
      return Map<String, dynamic>.from(res as Map)['message']?.toString() ??
          'Opération effectuée.';
    } catch (_) {
      return 'Impossible d’exécuter l’opération pour le moment.';
    }
  }
}
