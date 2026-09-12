import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineSessionGate {
  static const _kSeen = 'offline:last_user_seen';
  static const _kNoCacheNoticeShown = 'offline:no_cache_notice_shown';
  final _local = LocalJsonCache();

  Future<void> markSeen() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kSeen, true);
    await p.remove(_kNoCacheNoticeShown);
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kSeen);
    await p.remove(_kNoCacheNoticeShown);
  }

  Future<bool> canEnterWithoutAuth() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kSeen) == true;
  }

  Future<bool> hasOfflineBootstrapData() async {
    final checks = await Future.wait([
      _local.hasKey('home:snapshot:v1'),
      _local.hasKey('user:profile'),
    ]);
    return checks.every((value) => value);
  }

  Future<bool> consumeNoCacheNotice() async {
    final p = await SharedPreferences.getInstance();
    if (p.getBool(_kNoCacheNoticeShown) == true) return false;
    await p.setBool(_kNoCacheNoticeShown, true);
    return true;
  }
}
