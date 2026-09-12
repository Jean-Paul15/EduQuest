import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl => _read('SUPABASE_URL');
  static String get supabasePublishableKey =>
      _pickKey('SUPABASE_PUBLISHABLE_KEYS') ??
      '';
  static String get oauthRedirectUrl => _read('SUPABASE_OAUTH_REDIRECT_URL');
  static String get oneSignalAppId => _read('ONESIGNAL_APP_ID');
  static String get homeWidgetAndroidName => _read('HOME_WIDGET_ANDROID_NAME');
  static String get homeWidgetIosName => _read('HOME_WIDGET_IOS_NAME');

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
  static bool get hasOneSignal => oneSignalAppId.isNotEmpty;

  static String _read(String key) {
    try {
      return dotenv.env[key] ?? '';
    } catch (_) {
      return '';
    }
  }

  static String? _pickKey(String name) {
    final raw = _read(name).trim();
    if (raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return _firstString(decoded);
    } catch (_) {
      return raw;
    }
  }

  static String? _firstString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value is Map) {
      final preferred = ['default', 'mobile', 'app', 'client', 'primary'];
      for (final key in preferred) {
        final hit = _firstString(value[key]);
        if (hit != null) return hit;
      }
      for (final entry in value.values) {
        final hit = _firstString(entry);
        if (hit != null) return hit;
      }
    }
    if (value is List) {
      for (final entry in value) {
        final hit = _firstString(entry);
        if (hit != null) return hit;
      }
    }
    return null;
  }
}
