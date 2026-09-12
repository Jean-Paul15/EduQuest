import 'dart:async';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserNotificationItem {
  const UserNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.deeplink,
    required this.readAt,
    required this.createdAt,
  });
  final String id, title, body, deeplink;
  final DateTime? readAt;
  final DateTime createdAt;
}

class UserNotificationsRepository {
  final _local = LocalJsonCache();
  static const _key = 'notifications:user_list';

  /// Rappels générés par les crons (révision espacée, relance IA sur une
  /// méprise) : livrés en push, mais volontairement absents du Hub — ce ne
  /// sont pas des notifications "importantes" à conserver dans la liste,
  /// juste des coups de pouce transitoires vers l'assistant/le chapitre.
  static const _hiddenFromHubSources = '(review,ai_notification)';

  // Contenu Hub : tolère jusqu'à 1 semaine de péremption avant de
  // rafraîchir en tâche de fond -- `forceRefresh` (pull-to-refresh) reste
  // le seul moyen de forcer un refetch immédiat.
  static const _ttl = Duration(days: 7);

  Future<List<UserNotificationItem>> list({bool forceRefresh = false}) async {
    final local = await _fromLocal();
    if (forceRefresh && Env.hasSupabase) {
      return await _refresh() ?? local;
    }
    if (!Env.hasSupabase) return local;
    if (local.isNotEmpty) {
      if (!await _local.isFresh(_key, _ttl)) unawaited(_refresh());
      return local;
    }
    return await _refresh() ?? local;
  }

  /// Compte des notifications non lues, toujours frais : requête ciblée qui
  /// ne passe pas par le cache TTL de [list] (7 jours). Ce compteur pilote la
  /// priorité et le badge de l'onglet Notifications dans le Hub — s'il est
  /// périmé, une nouvelle notification n'apparaît jamais en tête.
  Future<int> unreadCount() async {
    if (Env.hasSupabase) {
      try {
        final s = Supabase.instance.client;
        final uid = s.auth.currentUser?.id;
        if (uid != null) {
          final rows = await s
              .from('user_notifications')
              .select('id')
              .eq('profile_id', uid)
              .isFilter('read_at', null)
              .not('source', 'in', _hiddenFromHubSources);
          return (rows as List).length;
        }
      } catch (_) {}
    }
    return (await _fromLocal()).where((e) => e.readAt == null).length;
  }

  Future<void> markSeen(String id) async {
    await _markLocalSeen(id);
    if (!Env.hasSupabase) return;
    try {
      await Supabase.instance.client.rpc(
        'mark_user_notification_seen',
        params: {'p_notification_id': id},
      );
    } catch (_) {}
  }

  Future<List<UserNotificationItem>?> _refresh() async {
    try {
      final rows = await Supabase.instance.client
          .from('user_notifications')
          .select('id,title,body,deeplink,read_at,created_at')
          .not('source', 'in', _hiddenFromHubSources)
          .order('created_at', ascending: false)
          .limit(50);
      final out = (rows as List)
          .map((e) => _fromRow(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false);
      await _local.writeList(
        _key,
        out.map((e) => _toMap(e)).toList(growable: false),
      );
      return out;
    } catch (_) {
      return null;
    }
  }

  Future<List<UserNotificationItem>> _fromLocal() async {
    final rows = await _local.readList(_key);
    if (rows == null) return const [];
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<void> _markLocalSeen(String id) async {
    final rows = await _local.readList(_key);
    if (rows == null || rows.isEmpty) return;
    final now = DateTime.now().toIso8601String();
    var changed = false;
    final updated = rows.map((row) {
      if ('${row['id']}' != id || row['read_at'] != null) return row;
      changed = true;
      return {...row, 'read_at': now};
    }).toList();
    if (changed) await _local.writeList(_key, updated);
  }

  UserNotificationItem _fromRow(Map<dynamic, dynamic> e) {
    return UserNotificationItem(
      id: '${e['id']}',
      title: '${e['title'] ?? ''}',
      body: '${e['body'] ?? ''}',
      deeplink: '${e['deeplink'] ?? ''}',
      readAt: DateTime.tryParse('${e['read_at'] ?? ''}'),
      createdAt:
          DateTime.tryParse('${e['created_at'] ?? ''}') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _toMap(UserNotificationItem item) => {
    'id': item.id,
    'title': item.title,
    'body': item.body,
    'deeplink': item.deeplink,
    'read_at': item.readAt?.toIso8601String(),
    'created_at': item.createdAt.toIso8601String(),
  };
}
