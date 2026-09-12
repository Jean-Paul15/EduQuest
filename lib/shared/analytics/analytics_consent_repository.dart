import 'package:eduquest/shared/analytics/analytics_consent_state.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsConsentRepository {
  final _local = LocalJsonCache();

  Future<AnalyticsConsentState> get() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      return const AnalyticsConsentState(
        personalizationAi: false,
        aiImprovement: false,
      );
    }
    final cached = await _fromLocal(uid);
    if (!Env.hasSupabase) {
      return cached ??
          const AnalyticsConsentState(
            personalizationAi: false,
            aiImprovement: false,
          );
    }
    try {
      final row = await Supabase.instance.client
          .from('analytics_consent_preferences')
          .select('personalization_ai,ai_improvement')
          .eq('profile_id', uid)
          .maybeSingle();
      final state = AnalyticsConsentState(
        personalizationAi: row?['personalization_ai'] as bool? ?? false,
        aiImprovement: row?['ai_improvement'] as bool? ?? false,
      );
      await _writeLocal(uid, state);
      return state;
    } catch (_) {
      return cached ??
          const AnalyticsConsentState(
            personalizationAi: false,
            aiImprovement: false,
          );
    }
  }

  Future<void> save(AnalyticsConsentState state) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      return;
    }
    await _writeLocal(uid, state);
    if (!Env.hasSupabase) {
      return;
    }
    await Supabase.instance.client
        .from('analytics_consent_preferences')
        .upsert({
          'profile_id': uid,
          'personalization_ai': state.personalizationAi,
          'ai_improvement': state.aiImprovement,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
  }

  Future<AnalyticsConsentState?> _fromLocal(String uid) async {
    final rows = await _local.readList('analytics:consent:$uid');
    if (rows == null || rows.isEmpty) return null;
    final row = rows.first;
    return AnalyticsConsentState(
      personalizationAi: row['personalizationAi'] as bool? ?? false,
      aiImprovement: row['aiImprovement'] as bool? ?? false,
    );
  }

  Future<void> _writeLocal(String uid, AnalyticsConsentState state) {
    return _local.writeList('analytics:consent:$uid', [
      {
        'personalizationAi': state.personalizationAi,
        'aiImprovement': state.aiImprovement,
      },
    ]);
  }
}
