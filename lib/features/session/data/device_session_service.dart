import 'package:device_info_plus/device_info_plus.dart';
import 'package:eduquest/shared/network/network_probe.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeviceSessionService {
  static const _validationPrefix = 'session_validated_at_';
  static const _validationGrace = Duration(hours: 12);
  final _storage = const FlutterSecureStorage();

  Future<bool> ensureSingleDeviceSession() async {
    if (!Env.hasSupabase) return true;
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return false;
    final online = await NetworkProbe.hasConnection();
    if (!online) return true;
    final deviceId = await _deviceId();
    final token = await _sessionToken(uid);
    try {
      await Supabase.instance.client
          .rpc('claim_device_session', params: {
            'p_device_id': deviceId,
            'p_session_token_hash': token,
          })
          .timeout(const Duration(seconds: 4));
      final ok = await Supabase.instance.client
          .rpc('is_device_session_valid', params: {
            'p_device_id': deviceId,
            'p_session_token_hash': token,
          })
          .timeout(const Duration(seconds: 4));
      if (ok == true) {
        await _rememberValidation(uid);
      }
      return ok == true;
    } catch (_) {
      final stillOnline = await NetworkProbe.hasConnection();
      if (!stillOnline) return true;
      return _hasRecentValidation(uid);
    }
  }

  Future<void> clearLocalState(String uid) async {
    await _storage.delete(key: 'session_token_$uid');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_validationPrefix$uid');
  }

  Future<String> _sessionToken(String uid) async {
    final key = 'session_token_$uid';
    final existing = await _storage.read(key: key);
    if (existing != null) return existing;
    final token = '${DateTime.now().millisecondsSinceEpoch}-$uid';
    await _storage.write(key: key, value: token);
    return token;
  }

  Future<String> _deviceId() async {
    final info = DeviceInfoPlugin();
    try {
      final android = await info.androidInfo;
      return android.id;
    } catch (_) {
      final ios = await info.iosInfo;
      return ios.identifierForVendor ?? 'ios-unknown';
    }
  }

  Future<void> _rememberValidation(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_validationPrefix$uid',
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<bool> _hasRecentValidation(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_validationPrefix$uid');
    final last = raw == null ? null : DateTime.tryParse(raw);
    if (last == null) return false;
    return DateTime.now().toUtc().difference(last) <= _validationGrace;
  }
}
