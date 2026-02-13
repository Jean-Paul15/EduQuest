import 'package:eduquest/shared/config/env.dart';
import 'package:http/http.dart' as http;

class NetworkProbe {
  static Future<bool> hasConnection() async {
    final uri = _targetUri();
    if (uri == null) return false;
    try {
      final r = await http
          .get(uri, headers: _headers())
          .timeout(const Duration(seconds: 2));
      return r.statusCode > 0 && r.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  static Uri? _targetUri() {
    if (Env.hasSupabase) {
      return Uri.tryParse('${Env.supabaseUrl}/rest/v1/');
    }
    return Uri.tryParse('https://clients3.google.com/generate_204');
  }

  static Map<String, String>? _headers() {
    if (!Env.hasSupabase) return null;
    return {
      'apikey': Env.supabaseAnonKey,
      'Authorization': 'Bearer ${Env.supabaseAnonKey}',
    };
  }
}
