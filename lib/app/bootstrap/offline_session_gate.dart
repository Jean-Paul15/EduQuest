import 'package:shared_preferences/shared_preferences.dart';

class OfflineSessionGate {
  static const _kSeen = 'offline:last_user_seen';

  Future<void> markSeen() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kSeen, true);
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kSeen);
  }

  Future<bool> canEnterWithoutAuth() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kSeen) == true;
  }
}
