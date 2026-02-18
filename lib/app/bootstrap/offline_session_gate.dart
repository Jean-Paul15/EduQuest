import 'package:shared_preferences/shared_preferences.dart';

class OfflineSessionGate {
  static const _kSeen = 'offline:last_user_seen';
  static const _kNoCacheNoticeShown = 'offline:no_cache_notice_shown';

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

  Future<bool> consumeNoCacheNotice() async {
    final p = await SharedPreferences.getInstance();
    if (p.getBool(_kNoCacheNoticeShown) == true) return false;
    await p.setBool(_kNoCacheNoticeShown, true);
    return true;
  }
}
