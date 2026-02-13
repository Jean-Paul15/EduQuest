import 'package:shared_preferences/shared_preferences.dart';

class OnboardingGateService {
  static const _key = 'onboarding_seen_v1';

  Future<bool> isSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
