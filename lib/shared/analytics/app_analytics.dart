import 'dart:async';
import 'dart:math';
import 'package:eduquest/shared/analytics/analytics_consent_repository.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/core/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/local_json_cache.dart';
import '../sync/service_locator.dart';

class AppAnalytics {
  static _EventContext? _cache;
  static DateTime? _cacheAt;
  static Timer? _flushTimer;
  static String? _sessionId;
  static int _pending = 0;
  static const _ttl = Duration(minutes: 5);
  static final _local = LocalJsonCache();
  static final _consent = AnalyticsConsentRepository();

  Future<void> track(
    String eventName, {
    String? category,
    String? targetType,
    String? targetId,
    Map<String, dynamic>? payload,
    bool? requiresConsent,
    int priority = 1,
    String source = 'app',
  }) async {
    if (!Env.hasSupabase) {
      return;
    }
    if ((requiresConsent ?? _needsConsent(eventName, category)) &&
        !await _hasConsent()) {
      return;
    }
    final row = await _eventRow(
      eventName,
      category,
      targetType,
      targetId,
      payload,
      source,
    );
    await ServiceLocator().queue.enqueue(
      operation: SyncOp.rpc,
      targetTable: AppRpc.ingestAppEvents,
      payload: row,
    );
    _pending++;
    if (priority <= 0 || _pending >= 25) {
      flushNow();
    } else {
      _scheduleFlush();
    }
  }

  void flushNow() {
    _flushTimer?.cancel();
    _flushTimer = null;
    _pending = 0;
    ServiceLocator().sync.tryFlushNow();
  }

  Future<Map<String, dynamic>> _eventRow(
    String eventName,
    String? category,
    String? targetType,
    String? targetId,
    Map<String, dynamic>? payload,
    String source,
  ) async {
    final ctx = await _loadContext();
    final oracle = ServiceLocator().oracle;
    return {
      'profile_id': Supabase.instance.client.auth.currentUser?.id,
      'session_id': await _ensureSessionId(),
      'event_name': eventName,
      'event_category': category,
      'event_source': source,
      'event_version': 1,
      'event_time': DateTime.now().toUtc().toIso8601String(),
      'platform': ctx.platform,
      'app_version': ctx.appVersion,
      'connection_type': oracle.state.name,
      'device_type': _deviceType(),
      'dedupe_key': _pseudoUuid(),
      'country_code': ctx.countryCode,
      'education_level_code': ctx.levelCode,
      'series_code': ctx.serieCode,
      'is_offline': !oracle.isOnline,
      'payload': _cleanPayload({
        ...?payload,
        if (targetType != null) 'target_type': targetType,
        if (targetId != null) 'target_id': targetId,
      }),
    };
  }

  Future<_EventContext> _loadContext() async {
    final now = DateTime.now();
    if (_cache != null &&
        _cacheAt != null &&
        now.difference(_cacheAt!) < _ttl) {
      return _cache!;
    }
    String? appVersion;
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion = '${info.version}+${info.buildNumber}';
    } catch (_) {}
    final local = await _local.readList('user:profile');
    final row = local?.isNotEmpty == true
        ? local!.first
        : const <String, dynamic>{};
    final out = _EventContext(
      platform: _platformName(),
      appVersion: appVersion,
      countryCode: _readTrim(row, 'countryCode'),
      levelCode: _readTrim(row, 'levelCode'),
      serieCode: _readTrim(row, 'serieCode'),
    );
    _cache = out;
    _cacheAt = now;
    return out;
  }

  Future<bool> _hasConsent() async =>
      (await _consent.get()).allowsLearningAnalytics;

  bool _needsConsent(String eventName, String? category) {
    const exempt = {
      'auth',
      'notification',
      'payment',
      'session',
      'support',
      'technical',
    };
    if (category != null && exempt.contains(category)) {
      return false;
    }
    return !(eventName.startsWith('push_') ||
        eventName.startsWith('sync_') ||
        eventName.startsWith('session_'));
  }

  void _scheduleFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer(const Duration(seconds: 30), flushNow);
  }

  Future<String> _ensureSessionId() async {
    if (_sessionId != null) {
      return _sessionId!;
    }
    final prefs = await SharedPreferences.getInstance();
    _sessionId =
        prefs.getString(AppStorageKeys.analyticsSessionId) ?? _pseudoUuid();
    await prefs.setString(AppStorageKeys.analyticsSessionId, _sessionId!);
    return _sessionId!;
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

  String _deviceType() => kIsWeb
      ? 'web'
      : switch (defaultTargetPlatform) {
          TargetPlatform.android || TargetPlatform.iOS => 'mobile',
          _ => 'desktop',
        };

  String _pseudoUuid() {
    final rand = Random.secure();
    String hex(int len) =>
        List.generate(len, (_) => rand.nextInt(16).toRadixString(16)).join();
    return '${hex(8)}-${hex(4)}-4${hex(3)}-a${hex(3)}-${hex(12)}';
  }

  String? _readTrim(Map<dynamic, dynamic> row, String key) {
    final value = row[key]?.toString().trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  Map<String, dynamic> _cleanPayload(Map<String, dynamic> payload) {
    final out = <String, dynamic>{};
    for (final entry in payload.entries) {
      final value = entry.value;
      if (value == null) continue;
      if (value is num || value is bool || value is String) {
        out[entry.key] = value;
      } else {
        out[entry.key] = value.toString();
      }
    }
    return out;
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
}
