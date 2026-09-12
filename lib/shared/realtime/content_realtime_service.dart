import 'dart:async';

import 'package:eduquest/features/learning/data/learning_scope_repository.dart';
import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/realtime/cache_invalidation_bus.dart';
import 'package:eduquest/shared/realtime/cache_signal.dart';
import 'package:eduquest/shared/realtime/content_catchup.dart';
import 'package:eduquest/shared/sync/scope_refresh_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remplace `RealtimeAutoSyncService` : un seul canal Broadcast prive par serie
/// (`content:series:<id>`) + `content:global`. Un changement backend cible ->
/// [CacheInvalidationBus] evince la cle exacte -> l'ecran monte se recharge.
///
/// Robustesse : aucune methode publique ne peut lever ; toute erreur reseau /
/// plateforme / auth est capturee et journalisee, l'app continue de servir le
/// cache. Un `resync()` ulterieur (reveil, retour reseau) retentera.
class ContentRealtimeService {
  ContentRealtimeService._();
  static final ContentRealtimeService instance = ContentRealtimeService._();

  final _catchUp = ContentCatchUp();
  final _bus = CacheInvalidationBus.instance;
  RealtimeChannel? _seriesCh, _globalCh, _progressCh;
  String? _seriesTopic;
  StreamSubscription<AuthState>? _authSub;
  ScopeContext _scope = const ScopeContext();
  bool _started = false;
  bool _resyncing = false;

  Future<void> start() async {
    if (_started || !Env.hasSupabase) return;
    _started = true;
    try {
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
        (s) async {
          final tok = s.session?.accessToken;
          if (tok == null) return;
          try {
            await Supabase.instance.client.realtime.setAuth(tok);
          } catch (e) {
            debugPrint('ContentRealtime setAuth(onAuthChange) error: $e');
          }
        },
        onError: (Object e) => debugPrint('ContentRealtime auth stream: $e'),
      );
      ScopeRefreshBus.listenable.addListener(_onScopeBump);
    } catch (e) {
      debugPrint('ContentRealtime start error: $e');
    }
    await resync();
  }

  void _onScopeBump() => unawaited(onSeriesChanged());

  /// (Re)resout le scope, (re)abonne les canaux, lance le rattrapage.
  /// Appele au demarrage, au retour au premier plan et au retour du reseau.
  Future<void> resync() async {
    if (!Env.hasSupabase || _resyncing) return;
    _resyncing = true;
    try {
      await _resolveScope();
      if (!_scope.isResolved) return;
      try {
        final tok = Supabase.instance.client.auth.currentSession?.accessToken;
        if (tok != null) await Supabase.instance.client.realtime.setAuth(tok);
      } catch (e) {
        debugPrint('ContentRealtime setAuth error: $e');
      }
      _subscribe();
      await _catchUp.run(_scope);
    } catch (e) {
      debugPrint('ContentRealtime resync error: $e');
    } finally {
      _resyncing = false;
    }
  }

  Future<void> onSeriesChanged() async {
    try {
      await _unsubscribe();
      await _catchUp.resetTimestamp();
      // Nouveau scope : tout le contenu affiche doit se recharger.
      _bus.emit(const CacheSignal(hint: '*'));
    } catch (e) {
      debugPrint('ContentRealtime onSeriesChanged error: $e');
    }
    await resync();
  }

  Future<void> stop() async {
    ScopeRefreshBus.listenable.removeListener(_onScopeBump);
    await _unsubscribe();
    try {
      await _authSub?.cancel();
    } catch (_) {}
    _authSub = null;
    _started = false;
  }

  Future<void> _resolveScope() async {
    try {
      final s = await LearningScopeRepository().current();
      final p = await UserProfileRepository().load();
      _scope = ScopeContext(
        seriesId: s?.seriesId,
        levelId: s?.levelId,
        countryId: s?.countryId,
        seriesCode: p.serieCode,
        levelCode: p.levelCode,
      );
      _bus.setScope(_scope);
    } catch (e) {
      debugPrint('ContentRealtime scope error: $e');
    }
  }

  void _subscribe() {
    try {
      final client = Supabase.instance.client;
      _globalCh ??= client
          .channel('content:global',
              opts: const RealtimeChannelConfig(private: true))
          .onBroadcast(event: 'content_change', callback: _onEvent)
          .subscribe();
      final topic = 'content:series:${_scope.sid}';
      if (_seriesTopic != topic) {
        _seriesCh?.unsubscribe();
        _seriesTopic = topic;
        _seriesCh = client
            .channel(topic, opts: const RealtimeChannelConfig(private: true))
            .onBroadcast(event: 'content_change', callback: _onEvent)
            .subscribe();
      }
      // Maîtrise : canal prive par élève (pas par série, cf mig 221e) — le
      // backend est la seule source qui déclenche un rechargement, y compris
      // pour le propre écrit de l'appareil (aucune éviction manuelle côté client).
      final uid = client.auth.currentUser?.id;
      if (uid != null) {
        _progressCh ??= client
            .channel('learn:progress:$uid',
                opts: const RealtimeChannelConfig(private: true))
            .onBroadcast(event: 'content_change', callback: _onEvent)
            .subscribe();
      }
    } catch (e) {
      debugPrint('ContentRealtime subscribe error: $e');
      _seriesTopic = null; // force une nouvelle tentative au prochain resync
    }
  }

  Future<void> _unsubscribe() async {
    try {
      await _seriesCh?.unsubscribe();
      await _globalCh?.unsubscribe();
      await _progressCh?.unsubscribe();
    } catch (_) {}
    _seriesCh = null;
    _globalCh = null;
    _progressCh = null;
    _seriesTopic = null;
  }

  void _onEvent(Map<String, dynamic> payload) {
    try {
      final body = payload['payload'] is Map
          ? Map<String, dynamic>.from(payload['payload'] as Map)
          : payload;
      _bus.emit(CacheSignal.fromBroadcast(body));
    } catch (e) {
      debugPrint('ContentRealtime onEvent error: $e');
    }
  }
}
