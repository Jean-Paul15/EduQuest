import 'dart:async';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardRepository {
  final _local = LocalJsonCache();

  Future<List<Map<String, dynamic>>> weekly() async {
    final local = await _fromLocalWeekly() ?? const <Map<String, dynamic>>[];
    if (!Env.hasSupabase) return local;
    if (local.isNotEmpty) {
      unawaited(_refreshWeekly());
      return local;
    }
    return await _refreshWeekly() ?? local;
  }

  Future<Map<String, dynamic>> monthlyPolicy() async {
    final local = await _fromLocalPolicy();
    if (!Env.hasSupabase) return local ?? _defaultPolicy();
    if (local != null) {
      unawaited(_refreshPolicy());
      return local;
    }
    return await _refreshPolicy() ?? _defaultPolicy();
  }

  Future<List<Map<String, dynamic>>?> _refreshWeekly() async {
    try {
      await Supabase.instance.client.rpc('build_weekly_leaderboard');
      final row = await Supabase.instance.client
          .from('weekly_leaderboards')
          .select('ranking')
          .eq('scope', 'GLOBAL')
          .order('generated_at', ascending: false)
          .limit(1)
          .maybeSingle();
      final items = ((row?['ranking'] as List?) ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      await _local.writeList('leaderboard:weekly', items);
      return items;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _refreshPolicy() async {
    try {
      final row = await Supabase.instance.client
          .from('monthly_reward_policies')
          .select('enabled,reward_note,min_score')
          .order('period_key', ascending: false)
          .limit(1)
          .maybeSingle();
      final out = row == null
          ? _defaultPolicy()
          : Map<String, dynamic>.from(row);
      await _local.writeList('leaderboard:policy', [out]);
      return out;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _defaultPolicy() => {
    'enabled': false,
    'reward_note': null,
    'min_score': 40,
  };

  Future<List<Map<String, dynamic>>?> _fromLocalWeekly() async =>
      await _local.readList('leaderboard:weekly');
  Future<Map<String, dynamic>?> _fromLocalPolicy() async {
    final rows = await _local.readList('leaderboard:policy');
    return rows == null || rows.isEmpty ? null : rows.first;
  }
}
