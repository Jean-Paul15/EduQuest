import 'package:eduquest/shared/config/env.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushSubscriptionRepository {
  Future<void> sync({
    required String subscriptionId,
    required String token,
    required bool optedIn,
    required bool permissionGranted,
  }) async {
    if (!Env.hasSupabase || subscriptionId.isEmpty) return;
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await Supabase.instance.client.rpc(
        'upsert_push_subscription',
        params: {
          'p_subscription_id': subscriptionId,
          'p_token': token,
          'p_opted_in': optedIn,
          'p_permission_granted': permissionGranted,
          'p_platform': _platform(),
        },
      );
    } catch (_) {}
  }

  String _platform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'other';
    }
  }
}
