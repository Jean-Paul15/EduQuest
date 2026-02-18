import 'package:eduquest/shared/config/env.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local_json_cache.dart';

class AppAnalytics {
  static _EventContext? _cache;
  static DateTime? _cacheAt;
  static const _ttl = Duration(minutes: 5);
  static final _local = LocalJsonCache();

  Future<void> track(String eventName, {Map<String, dynamic>? payload}) async {
    if (!Env.hasSupabase) return;
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final ctx = await _loadContext(client, uid);
      if (!ctx.isComplete) return;
      await client.from('app_events').insert({
        'profile_id': uid,
        'event_name': eventName,
        'platform': ctx.platform,
        'app_version': ctx.appVersion,
        'country_code': ctx.countryCode,
        'education_level_code': ctx.levelCode,
        'series_code': ctx.serieCode,
        'payload': payload ?? <String, dynamic>{},
        'is_offline': false,
      });
    } catch (_) {}
  }

  Future<_EventContext> _loadContext(SupabaseClient client, String uid) async {
    final now = DateTime.now();
    if (_cache != null && _cacheAt != null && now.difference(_cacheAt!) < _ttl) {
      return _cache!;
    }
    final platform = _platformName();
    String? appVersion;
    String? countryCode;
    String? levelCode;
    String? serieCode;
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion = '${info.version}+${info.buildNumber}';
    } catch (_) {}
    final ids = await _profileIds(client, uid);
    countryCode = await _code(client, 'countries', ids.$1);
    levelCode = await _code(client, 'education_levels', ids.$2);
    serieCode = await _code(client, 'series', ids.$3);
    if (countryCode == null || levelCode == null || serieCode == null) {
      final local = await _localCodes();
      countryCode ??= local.$1;
      levelCode ??= local.$2;
      serieCode ??= local.$3;
    }
    final out = _EventContext(
      platform: platform,
      appVersion: appVersion,
      countryCode: countryCode,
      levelCode: levelCode,
      serieCode: serieCode,
    );
    _cache = out;
    _cacheAt = now;
    return out;
  }

  Future<(dynamic, dynamic, dynamic)> _profileIds(
    SupabaseClient client,
    String uid,
  ) async {
    try {
      final row = await client
          .from('profiles')
          .select('country_id,education_level_id,series_id')
          .eq('id', uid)
          .maybeSingle();
      return (row?['country_id'], row?['education_level_id'], row?['series_id']);
    } catch (_) {
      return (null, null, null);
    }
  }

  Future<String?> _code(SupabaseClient client, String table, dynamic id) async {
    if (id == null) return null;
    try {
      final row = await client.from(table).select('code').eq('id', id).maybeSingle();
      final code = row?['code']?.toString().trim();
      return (code == null || code.isEmpty) ? null : code;
    } catch (_) {
      return null;
    }
  }

  Future<(String?, String?, String?)> _localCodes() async {
    try {
      final rows = await _local.readList('user:profile');
      if (rows == null || rows.isEmpty) return (null, null, null);
      final r = rows.first;
      String? val(String k) {
        final v = r[k]?.toString().trim();
        return (v == null || v.isEmpty) ? null : v;
      }
      return (val('countryCode'), val('levelCode'), val('serieCode'));
    } catch (_) {
      return (null, null, null);
    }
  }

  String _platformName() {
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }
}

class _EventContext {
  const _EventContext({
    required this.platform,
    required this.appVersion,
    required this.countryCode,
    required this.levelCode,
    required this.serieCode,
  });

  final String platform;
  final String? appVersion;
  final String? countryCode;
  final String? levelCode;
  final String? serieCode;

  bool get isComplete =>
      appVersion != null &&
      countryCode != null &&
      levelCode != null &&
      serieCode != null;
}
