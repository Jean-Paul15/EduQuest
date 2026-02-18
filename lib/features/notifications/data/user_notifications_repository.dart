import 'package:eduquest/shared/config/env.dart';
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
  Future<List<UserNotificationItem>> list() async {
    if (!Env.hasSupabase) return const [];
    try {
      final rows = await Supabase.instance.client
          .from('user_notifications')
          .select('id,title,body,deeplink,read_at,created_at')
          .order('created_at', ascending: false)
          .limit(50);
      return (rows as List).map((e) {
        return UserNotificationItem(
          id: '${e['id']}',
          title: '${e['title'] ?? ''}',
          body: '${e['body'] ?? ''}',
          deeplink: '${e['deeplink'] ?? ''}',
          readAt: DateTime.tryParse('${e['read_at'] ?? ''}'),
          createdAt:
              DateTime.tryParse('${e['created_at'] ?? ''}') ?? DateTime.now(),
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> markSeen(String id) async {
    if (!Env.hasSupabase) return;
    try {
      await Supabase.instance.client.rpc(
        'mark_user_notification_seen',
        params: {'p_notification_id': id},
      );
    } catch (_) {}
  }
}
