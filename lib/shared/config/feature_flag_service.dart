import 'dart:convert';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/core/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages feature flags per §11.8 of RUACHEDU_OFFLINE_FIRST.md.
/// Flags are cached locally in SharedPreferences for synchronous reads.
class FeatureFlagService {
  // ─── Flag key constants ───
  static const offlineContentDownload = 'offline_content_download';
  static const backgroundSync = 'background_sync';
  static const mediaEncryption = 'media_encryption';
  static const surveysV2 = 'surveys_v2';

  Map<String, bool>? _flags;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Fetch flags from Supabase `app_config` (keys like `feature_%`)
  /// and persist in SharedPreferences. Falls back to local cache if offline.
  Future<void> loadFlags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (Env.hasSupabase) {
        final rows = await Supabase.instance.client
            .from(AppTables.appConfig)
            .select('key, value')
            .like('key', 'feature_%');
        final flags = <String, bool>{};
        for (final row in rows) {
          final key = (row['key'] as String?) ?? '';
          final val = row['value'];
          flags[key] = _parseBool(val);
        }
        _flags = flags;
        await prefs.setString(AppStorageKeys.featureFlags, jsonEncode(flags));
      } else {
        _loadFromCache(prefs);
      }
    } catch (e) {
      debugPrint('FeatureFlagService: load failed — $e');
      final prefs = await SharedPreferences.getInstance();
      _loadFromCache(prefs);
    }
    _initialized = true;
  }

  /// Synchronous check — never blocks UI.
  bool isEnabled(String flagKey) => _flags?[flagKey] ?? false;

  void _loadFromCache(SharedPreferences prefs) {
    final raw = prefs.getString(AppStorageKeys.featureFlags);
    if (raw != null) {
      _flags = Map<String, bool>.from(
        Map<String, dynamic>.from(jsonDecode(raw) as Map)
            .map((k, v) => MapEntry(k, v is bool ? v : false)),
      );
    }
  }

  bool _parseBool(dynamic val) {
    if (val is bool) return val;
    if (val is String) return val.toLowerCase() == 'true';
    return false;
  }
}
