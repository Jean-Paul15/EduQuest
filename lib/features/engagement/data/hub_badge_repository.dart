import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/cache_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HubBadgeRepository {
  static const _key = 'hub_last_seen_at';
  static const _countKey = 'hub_unseen_count';
  static const _tsKey = 'hub_unseen_ts';
  static int? _memCount;
  static int? _memTs;

  Future<int> unseenCount() async {
    if (!Env.hasSupabase) return 0;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final cachedCount = _memCount ?? prefs.getInt(_countKey);
    final cachedTs = _memTs ?? prefs.getInt(_tsKey);
    if (cachedCount != null &&
        cachedTs != null &&
        now - cachedTs <= CachePolicy.hubBadge.inMilliseconds) {
      _memCount = cachedCount;
      _memTs = cachedTs;
      return cachedCount;
    }
    try {
      final lastSeen =
          DateTime.tryParse(prefs.getString(_key) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0).toUtc();
      final s = Supabase.instance.client;
      final c = await s
          .from('contests')
          .select('id')
          .gt('created_at', lastSeen.toIso8601String());
      final e = await s
          .from('events')
          .select('id')
          .gt('created_at', lastSeen.toIso8601String());
      final l = await s
          .from('live_classes')
          .select('id')
          .gt('created_at', lastSeen.toIso8601String());
      final v = await s
          .from('surveys')
          .select('id')
          .gt('created_at', lastSeen.toIso8601String());
      final out =
          (c as List).length +
          (e as List).length +
          (l as List).length +
          (v as List).length;
      _memCount = out;
      _memTs = now;
      await prefs.setInt(_countKey, out);
      await prefs.setInt(_tsKey, now);
      return out;
    } catch (_) {
      return cachedCount ?? 0;
    }
  }

  Future<void> markSeenNow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, DateTime.now().toUtc().toIso8601String());
    _memCount = 0;
    _memTs = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_countKey, 0);
    await prefs.setInt(_tsKey, _memTs!);
  }
}
