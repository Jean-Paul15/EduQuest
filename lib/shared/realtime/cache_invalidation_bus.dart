import 'dart:async';

import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/realtime/cache_signal.dart';
import 'package:eduquest/shared/realtime/content_cache_key_map.dart';
import 'package:flutter/foundation.dart';

/// Bus central d'invalidation ciblee. Un [CacheSignal] arrive (Broadcast ou
/// rattrapage) -> on evince UNIQUEMENT les cles de cache concernees (jamais un
/// `removeByPrefix` en masse comme l'ancien RealtimeAutoSyncService) puis on
/// notifie les ecrans montes via [stream] pour un rechargement en place.
class CacheInvalidationBus {
  CacheInvalidationBus._();
  static final CacheInvalidationBus instance = CacheInvalidationBus._();

  final _local = LocalJsonCache();
  final _controller = StreamController<CacheSignal>.broadcast();
  final _memEvictors = <void Function(CacheTargets targets)>[];
  final _pending = <String, CacheSignal>{};
  Timer? _debounce;
  ScopeContext _scope = const ScopeContext();

  Stream<CacheSignal> get stream => _controller.stream;

  void setScope(ScopeContext scope) => _scope = scope;

  /// Un repo enregistre ici comment purger ses Map `_mem` statiques pour des
  /// cles donnees (le `LocalJsonCache` seul ne suffit pas : les repos gardent
  /// une copie en RAM qui survit meme a `clearAll`).
  void registerMemEvictor(void Function(CacheTargets) evict) =>
      _memEvictors.add(evict);

  void emit(CacheSignal signal) {
    if (signal.hint.isEmpty) return;
    _pending[_dedupeKey(signal)] = signal;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _flush);
  }

  void emitAll(Iterable<CacheSignal> signals) {
    for (final s in signals) {
      if (s.hint.isNotEmpty) _pending[_dedupeKey(s)] = s;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _flush);
  }

  Future<void> _flush() async {
    _debounce?.cancel();
    _debounce = null;
    final batch = _pending.values.toList(growable: false);
    _pending.clear();
    if (!_scope.isResolved) return;
    final seenPrefix = <String>{};
    for (final signal in batch) {
      try {
        final targets = ContentCacheKeys.targetsFor(signal, _scope);
        for (final key in targets.exact) {
          if (key.trim().isEmpty) continue;
          await _local.removeByPrefix(key); // cle exacte, pas un vrai prefixe
        }
        for (final p in targets.prefixes) {
          if (seenPrefix.add(p)) await _local.removeByPrefix(p);
        }
        for (final evict in _memEvictors) {
          try {
            evict(targets);
          } catch (e) {
            debugPrint('CacheInvalidationBus evictor error: $e');
          }
        }
      } catch (e) {
        debugPrint('CacheInvalidationBus flush error ($signal): $e');
      }
      if (!_controller.isClosed) {
        try {
          _controller.add(signal);
        } catch (_) {}
      }
    }
  }

  String _dedupeKey(CacheSignal s) {
    final r = s.ref;
    return '${s.hint}|${r['chapter_id'] ?? ''}|${r['subject_id'] ?? ''}'
        '|${r['quiz_id'] ?? ''}|${r['type'] ?? ''}|${r['key'] ?? ''}';
  }

  @visibleForTesting
  Future<void> flushNow() => _flush();
}
