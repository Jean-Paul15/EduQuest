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

  Future<Map<String, bool>> loadHubModules() async {
    final value = await _value('hub_modules');
    return {
      'live': value['live'] as bool? ?? true,
      'contests': value['contests'] as bool? ?? true,
      'events': value['events'] as bool? ?? true,
      'surveys': value['surveys'] as bool? ?? true,
      'referral': value['referral'] as bool? ?? true,
      'market': value['market'] as bool? ?? true,
      'leaderboard': value['leaderboard'] as bool? ?? true,
      'orientation': value['orientation'] as bool? ?? true,
    };
  }

  Future<Map<String, String>> loadAppLinks() async {
    final value = await _value('app_links');
    return {
      'support_url': value['support_url']?.toString() ?? '',
      'ticket_shop_url': value['ticket_shop_url']?.toString() ?? '',
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
