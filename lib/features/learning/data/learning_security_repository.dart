import 'dart:async';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/cache_policy.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LearningSecurityPolicy {
  const LearningSecurityPolicy({
    required this.captureAllowed,
    required this.keepAwake,
  });
  final bool captureAllowed;
  final bool keepAwake;
}

class LearningSecurityRepository {
  final _local = LocalJsonCache();
  static LearningSecurityPolicy? _mem;

  Future<LearningSecurityPolicy> load() async {
    final cached = _mem;
    if (cached != null) {
      if (Env.hasSupabase &&
          !await _local.isFresh(
            'cfg:learning_security',
            CachePolicy.appConfig,
          )) {
        unawaited(_refresh());
      }
      return cached;
    }
    final local = await _fromLocal();
    if (local != null) {
      _mem = local;
      if (Env.hasSupabase &&
          !await _local.isFresh(
            'cfg:learning_security',
            CachePolicy.appConfig,
          )) {
        unawaited(_refresh());
      }
      return local;
    }
    if (!Env.hasSupabase) return _fallback();
    return await _refresh() ?? _fallback();
  }

  Future<LearningSecurityPolicy?> _refresh() async {
    try {
      final row = await Supabase.instance.client
          .from('app_config')
          .select('value')
          .eq('key', 'learning_security')
          .maybeSingle();
      final value = Map<String, dynamic>.from((row?['value'] as Map?) ?? {});
      final policy = _fromMap(value);
      _mem = policy;
      await _local.writeList('cfg:learning_security', [
        {'value': value},
      ]);
      return policy;
    } catch (_) {
      return null;
    }
  }

  Future<LearningSecurityPolicy?> _fromLocal() async {
    final rows = await _local.readList('cfg:learning_security');
    if (rows == null || rows.isEmpty) return null;
    return _fromMap(
      Map<String, dynamic>.from((rows.first['value'] as Map?) ?? {}),
    );
  }

  LearningSecurityPolicy _fromMap(Map<String, dynamic> value) {
    return LearningSecurityPolicy(
      captureAllowed: value['capture_allowed'] as bool? ?? true,
      keepAwake: value['keep_awake'] as bool? ?? true,
    );
  }

  LearningSecurityPolicy _fallback() =>
      const LearningSecurityPolicy(captureAllowed: true, keepAwake: true);
}
