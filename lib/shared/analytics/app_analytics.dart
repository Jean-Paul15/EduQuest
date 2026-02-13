import 'package:eduquest/shared/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppAnalytics {
  Future<void> track(String eventName, {Map<String, dynamic>? payload}) async {
    if (!Env.hasSupabase) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await Supabase.instance.client.from('app_events').insert({
        'profile_id': userId,
        'event_name': eventName,
        'platform': 'flutter',
        'payload': payload ?? <String, dynamic>{},
        'is_offline': false,
      });
    } catch (_) {}
  }
}
