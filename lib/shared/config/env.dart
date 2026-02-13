import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl => _read('SUPABASE_URL');
  static String get supabaseAnonKey => _read('SUPABASE_ANON_KEY');
  static String get oauthRedirectUrl => _read('SUPABASE_OAUTH_REDIRECT_URL');
  static String get oneSignalAppId => _read('ONESIGNAL_APP_ID');
  static String get homeWidgetAndroidName => _read('HOME_WIDGET_ANDROID_NAME');
  static String get homeWidgetIosName => _read('HOME_WIDGET_IOS_NAME');
  static String get geminiApiKey => _read('GEMINI_API_KEY');
  static String get geminiModel => _read('GEMINI_MODEL');

  static bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static bool get hasOneSignal => oneSignalAppId.isNotEmpty;
  static bool get hasGemini => geminiApiKey.isNotEmpty;

  static String _read(String key) {
    try {
      return dotenv.env[key] ?? '';
    } catch (_) {
      return '';
    }
  }
}
