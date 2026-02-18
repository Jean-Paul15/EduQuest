import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/cache_policy.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HubBadgeRepository {
  static const _countKey = 'hub_unseen_count';
  static const _tsKey = 'hub_unseen_ts';
  static int? _memCount;
  static int? _memTs;
  final _local = LocalJsonCache();
  final _config = AppConfigRepository();

  Future<int> unseenCount() async {
    final flags = await _loadFlags();
    if (!Env.hasSupabase) return _offlineFallback(flags);
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
      final s = Supabase.instance.client;
      Future<int> countRows(String table) async {
        final rows = await s.from(table).select('id');
        return (rows as List).length;
      }

      var out = 0;
      if (flags['live'] == true) out += await countRows('live_classes');
      if (flags['contests'] == true) out += await countRows('contests');
      if (flags['events'] == true) out += await countRows('events');
      if (flags['surveys'] == true) out += await _pendingSurveyCount(s);
      if (flags['notifications'] == true) {
        out += await _unreadNotificationsCount(s);
      }
      _memCount = out;
      _memTs = now;
      await prefs.setInt(_countKey, out);
      await prefs.setInt(_tsKey, now);
      return out;
    } catch (_) {
      if (cachedCount != null) return cachedCount;
      return _offlineFallback(flags);
    }
  }

  Future<void> markSeenNow() async {
    return;
  }

  Future<Map<String, bool>> _loadFlags() async {
    try {
      return await _config.loadHubModules();
    } catch (_) {
      return const {
        'live': true,
        'contests': true,
        'events': true,
        'surveys': true,
      };
    }
  }

  Future<int> _offlineFallback(Map<String, bool> flags) async {
    var out = 0;
    if (flags['contests'] == true) {
      out += (await _local.readList('hub:contests'))?.length ?? 0;
    }
    if (flags['events'] == true) {
      out += (await _local.readList('hub:events'))?.length ?? 0;
    }
    if (flags['surveys'] == true) {
      out += (await _local.readList('hub:surveys'))?.length ?? 0;
    }
    if (flags['live'] == true) {
      out += (await _local.readList('hub:lives'))?.length ?? 0;
    }
    _memCount = out;
    _memTs = DateTime.now().millisecondsSinceEpoch;
    return out;
  }

  Future<int> _pendingSurveyCount(SupabaseClient s) async {
    final uid = s.auth.currentUser?.id;
    final rows = await s
        .from('surveys')
        .select('id')
        .eq('is_visible', true)
        .gte('ends_at', DateTime.now().toUtc().toIso8601String());
    final ids = (rows as List).map((e) => '${e['id']}').toList();
    if (uid == null || ids.isEmpty) return ids.length;
    final ans = await s
        .from('survey_answers')
        .select('survey_id')
        .eq('profile_id', uid)
        .inFilter('survey_id', ids);
    final answered = (ans as List).map((e) => '${e['survey_id']}').toSet();
    return ids.where((id) => !answered.contains(id)).length;
  }

  Future<int> _unreadNotificationsCount(SupabaseClient s) async {
    try {
      final uid = s.auth.currentUser?.id;
      if (uid == null) return 0;
      final rows = await s
          .from('user_notifications')
          .select('id')
          .eq('profile_id', uid)
          .isFilter('read_at', null);
      return (rows as List).length;
    } catch (_) {
      return 0;
    }
  }
}
