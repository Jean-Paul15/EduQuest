import 'package:eduquest/shared/realtime/cache_invalidation_bus.dart';
import 'package:eduquest/shared/realtime/cache_signal.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Rattrapage des changements manques (retour en ligne, reveil, relance a froid).
/// Le temps reel ne rejoue pas les evenements : on demande au serveur, via
/// `content_changes_since`, ce qui a bouge depuis le dernier passage.
class ContentCatchUp {
  static const _tsKey = 'content:rt:last_sync_ts';
  static const _maxGap = Duration(days: 30); // = retention du journal serveur

  final _bus = CacheInvalidationBus.instance;

  Future<void> run(ScopeContext scope) async {
    if (!Env.hasSupabase || !scope.isResolved) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_tsKey);
      final now = DateTime.now().toUtc();
      final since = raw == null ? null : DateTime.tryParse(raw);

      if (since == null) {
        await prefs.setString(_tsKey, now.toIso8601String());
        return; // premier lancement : le cache se remplira a la demande
      }
      if (now.difference(since) > _maxGap) {
        _bus.emit(const CacheSignal(hint: '*')); // absence longue : reset scope
        await prefs.setString(_tsKey, now.toIso8601String());
        return;
      }

      final rows = await Supabase.instance.client.rpc(
        'content_changes_since',
        params: {
          'p_series': scope.seriesId,
          'p_since': since.toIso8601String(),
          'p_limit': 800,
        },
      );
      final list = (rows as List?) ?? const [];
      if (list.isNotEmpty) {
        _bus.emitAll(list.map(
          (e) => CacheSignal.fromCatchupRow(Map<String, dynamic>.from(e as Map)),
        ));
      }
      // On n'avance le curseur que si le RPC a repondu : un echec reseau garde
      // l'ancien timestamp pour retenter au prochain resync (aucune perte).
      await prefs.setString(_tsKey, now.toIso8601String());
    } catch (e) {
      debugPrint('ContentCatchUp run error: $e');
    }
  }

  Future<void> resetTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tsKey, DateTime.now().toUtc().toIso8601String());
    } catch (e) {
      debugPrint('ContentCatchUp resetTimestamp error: $e');
    }
  }
}
