import 'dart:async';
import 'package:eduquest/features/app_config/domain/auth_options.dart';
import 'package:eduquest/features/app_config/domain/update_policy.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/cache_policy.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfigRepository {
  final _local = LocalJsonCache();
  static final Map<String, Map<String, dynamic>> _mem = {};

  static void clearMemory([String? key]) {
    if (key == null) {
      _mem.clear();
      return;
    }
    _mem.remove(key);
  }

  Future<AuthOptions> loadAuthOptions() async {
    final value = await _value('auth_options');
    return AuthOptions(
      google: value['google'] as bool? ?? true,
      apple: value['apple'] as bool? ?? true,
      emailPassword: value['email_password'] as bool? ?? true,
    );
  }

  Future<UpdatePolicy> loadUpdatePolicy(String platform) async {
    final value = await _value('app_update_policy');
    final p = Map<String, dynamic>.from((value[platform] as Map?) ?? {});
    return UpdatePolicy(
      enabled: value['enabled'] as bool? ?? false,
      message: value['message']?.toString() ?? '',
      enforceExactMatch: value['enforce_exact_match'] as bool? ?? false,
      platform: p,
    );
  }

  Future<Map<String, bool>> loadHubModules({bool forceRefresh = false}) async {
    final value = forceRefresh
        ? (await _refreshValue('hub_modules') ?? await _value('hub_modules'))
        : await _value('hub_modules');
    return {
      'live': value['live'] as bool? ?? true,
      'contests': value['contests'] as bool? ?? true,
      'events': value['events'] as bool? ?? true,
      'surveys': value['surveys'] as bool? ?? true,
      'notifications': value['notifications'] as bool? ?? true,
      'referral': value['referral'] as bool? ?? true,
      'market': value['market'] as bool? ?? true,
      'leaderboard': value['leaderboard'] as bool? ?? true,
      'orientation': value['orientation'] as bool? ?? true,
    };
  }

  Future<Map<String, String>> loadAppLinks({bool forceRefresh = false}) async {
    final value = forceRefresh
        ? (await _refreshValue('app_links') ?? await _value('app_links'))
        : await _value('app_links');
    final base = value['site_base_url']?.toString() ?? '';
    String norm(String raw) {
      final v = raw.trim();
      if (v.isEmpty) return '';
      if (v.startsWith('http://') || v.startsWith('https://')) return v;
      if (base.trim().isEmpty) return v;
      final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
      final p = v.startsWith('/') ? v : '/$v';
      return '$b$p';
    }
    return {
      'support_url': norm(value['support_url']?.toString() ?? ''),
      'ticket_shop_url': norm(value['ticket_shop_url']?.toString() ?? ''),
      'site_base_url': base,
      'handoff_path': value['handoff_path']?.toString() ?? '',
      'payment_path': value['payment_path']?.toString() ?? '',
      'public_event_buy_path': value['public_event_buy_path']?.toString() ?? '',
      'ticket_checkout_path': value['ticket_checkout_path']?.toString() ?? '',
    };
  }

  Future<Map<String, dynamic>> loadFeedModules() async {
    final value = await _value('feed_modules');
    return {
      'courses': value['courses'] as bool? ?? true,
      'contests': value['contests'] as bool? ?? true,
      'events': value['events'] as bool? ?? true,
      'courses_limit': value['courses_limit'] as int? ?? 8,
      'contests_limit': value['contests_limit'] as int? ?? 5,
      'events_limit': value['events_limit'] as int? ?? 5,
    };
  }

  Future<Map<String, String>> loadLearningAccess() async {
    final value = await _value('learning_access');
    return {
      'courses': value['courses']?.toString().toUpperCase() ?? 'HALF',
      'exams': value['exams']?.toString().toUpperCase() ?? 'HALF',
      'epreuves': value['epreuves']?.toString().toUpperCase() ?? 'HALF',
      'mockExams': value['mockExams']?.toString().toUpperCase() ?? 'FULL',
      'videos': value['videos']?.toString().toUpperCase() ?? 'HALF',
      'youtube': value['youtube']?.toString().toUpperCase() ?? 'HALF',
    };
  }

  Future<Map<String, dynamic>> _value(String key) async {
    final mem = _mem[key];
    if (mem != null) {
      if (Env.hasSupabase &&
          !await _local.isFresh('cfg:$key', CachePolicy.appConfig)) {
        unawaited(_refreshValue(key));
      }
      return mem;
    }
    final local = await _local.readList('cfg:$key');
    final localValue = local?.isNotEmpty == true
        ? Map<String, dynamic>.from((local!.first['value'] as Map?) ?? {})
        : <String, dynamic>{};
    if (localValue.isNotEmpty) _mem[key] = localValue;
    if (!Env.hasSupabase) return localValue;
    if (localValue.isNotEmpty) {
      if (!await _local.isFresh('cfg:$key', CachePolicy.appConfig)) {
        unawaited(_refreshValue(key));
      }
      return localValue;
    }
    return await _refreshValue(key) ?? localValue;
  }

  Future<Map<String, dynamic>?> _refreshValue(String key) async {
    try {
      final row = await Supabase.instance.client
          .from('app_config')
          .select('value')
          .eq('key', key)
          .maybeSingle();
      final value = Map<String, dynamic>.from((row?['value'] as Map?) ?? {});
      _mem[key] = value;
      await _local.writeList('cfg:$key', [
        {'value': value},
      ]);
      return value;
    } catch (_) {
      return null;
    }
  }
}
