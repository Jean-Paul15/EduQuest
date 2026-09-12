import 'dart:async';

import 'package:eduquest/shared/realtime/cache_invalidation_bus.dart';
import 'package:eduquest/shared/realtime/cache_signal.dart';
import 'package:flutter/widgets.dart';

/// Branche un ecran de liste sur le bus d'invalidation : quand une donnee de
/// son perimetre change en backend, l'ecran se recharge en place (debounce),
/// sans que l'utilisateur quitte ni tire pour rafraichir. Generalise le pattern
/// `HomeRealtime -> refresh() -> setState`.
///
/// L'ecran fournit :
///   - [realtimeNamespaces] : les namespaces qui le concernent
///     (`chapter`, `learn`, `exam`, `hub:contests`, `cfg`, `leaderboard`, `market`, ...)
///   - [reloadFromRealtime] : typiquement `=> _load(background: true)`.
mixin RealtimeRefreshable<T extends StatefulWidget> on State<T> {
  StreamSubscription<CacheSignal>? _rtSub;
  Timer? _rtDebounce;

  List<String> get realtimeNamespaces;

  Future<void> reloadFromRealtime();

  @override
  void initState() {
    super.initState();
    _rtSub = CacheInvalidationBus.instance.stream.listen(_onSignal);
  }

  @override
  void dispose() {
    _rtSub?.cancel();
    _rtDebounce?.cancel();
    super.dispose();
  }

  void _onSignal(CacheSignal s) {
    if (!s.isScopeReset) {
      final ns = s.namespace;
      final match = realtimeNamespaces.any(
        (own) => ns == own || ns.startsWith('$own:') || own.startsWith('$ns:'),
      );
      if (!match) return;
    }
    _rtDebounce?.cancel();
    _rtDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      try {
        reloadFromRealtime().catchError((Object e) {
          debugPrint('RealtimeRefreshable reload error: $e');
        });
      } catch (e) {
        debugPrint('RealtimeRefreshable reload threw: $e');
      }
    });
  }
}
