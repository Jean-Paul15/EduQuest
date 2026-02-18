import 'package:device_info_plus/device_info_plus.dart';
import 'package:eduquest/shared/network/network_probe.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeviceSessionService {
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
      await Supabase.instance.client.rpc('claim_device_session', params: {
        'p_device_id': deviceId,
        'p_session_token_hash': token,
      });
      final ok = await Supabase.instance.client.rpc('is_device_session_valid', params: {
        'p_device_id': deviceId,
        'p_session_token_hash': token,
      });
      return ok == true;
    } catch (_) {
      final stillOnline = await NetworkProbe.hasConnection();
      if (!stillOnline) return true;
      return false;
    }
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
}
