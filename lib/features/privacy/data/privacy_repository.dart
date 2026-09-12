import 'package:supabase_flutter/supabase_flutter.dart';

/// Accès aux fonctionnalités self-service de gouvernance des données
/// personnelles : export et demande de suppression de compte.
class PrivacyRepository {
  Future<void> requestAccountDeletion({String? reason}) async {
    await Supabase.instance.client.rpc(
      'request_data_deletion',
      params: {'p_reason': reason},
    );
  }

  Future<Map<String, dynamic>> exportMyData() async {
    final res = await Supabase.instance.client.rpc('export_my_data');
    return Map<String, dynamic>.from(res as Map);
  }
}
