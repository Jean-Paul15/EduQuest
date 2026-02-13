import 'package:eduquest/shared/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TicketActivationResult {
  final bool success;
  final String message;

  TicketActivationResult(this.success, this.message);
}

class TicketRepository {
  Future<TicketActivationResult> activateCode(String code) async {
    if (!Env.hasSupabase) {
      return TicketActivationResult(false, 'Supabase non configuré.');
    }
    final client = Supabase.instance.client;
    try {
      final result = await client.rpc('activate_ticket_code', params: {'p_code': code});
      final ok = result is Map && result['success'] == true;
      final message = result is Map ? '${result['message']}' : 'Réponse invalide.';
      return TicketActivationResult(ok, message);
    } catch (_) {
      return TicketActivationResult(false, 'Activation impossible.');
    }
  }
}
