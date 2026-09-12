import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Multi-level network state with hysteresis.
/// §10.2: Never trusts connectivity_plus alone — confirms with real HTTP probe.
enum ConnectionState {
  confirmedOnline,
  likelyOnline,
  captivePortal,
  slowConnection,
  offline,
}

class ConnectivityOracle extends ChangeNotifier {
  ConnectivityOracle({Duration? debounceWindow})
    : _debounceWindow = debounceWindow ?? const Duration(seconds: 10) {
    _init();
  }

  @visibleForTesting
  ConnectivityOracle.test(ConnectionState initialState)
    : _debounceWindow = Duration.zero,
      _state = initialState;

  final Duration _debounceWindow;
  final _connectivity = Connectivity();
  ConnectionState _state = ConnectionState.offline;
  DateTime _lastChange = DateTime(2000);
  StreamSubscription<List<ConnectivityResult>>? _sub;
  List<ConnectivityResult> _lastResults = [];
  Timer? _probeTimer;
  int _failCount = 0;
  static const _probeTimeout = Duration(seconds: 3),
      _retryDelay = Duration(seconds: 5);

  ConnectionState get state => _state;
  bool get isOnline =>
      _state == ConnectionState.confirmedOnline ||
      _state == ConnectionState.likelyOnline ||
      _state == ConnectionState.slowConnection;
  bool get isConfirmed => _state == ConnectionState.confirmedOnline;
  /// L'appareil a une interface réseau active (Wi-Fi/data) — ne dit rien sur
  /// la joignabilité réelle du backend, voir [isOnline]/[isConfirmed] pour ça.
  bool get hasDeviceNetwork =>
      _lastResults.isNotEmpty && !_lastResults.every((r) => r == ConnectivityResult.none);
  bool get isOnWifi => _lastResults.contains(ConnectivityResult.wifi);
  bool get isOnMobile =>
      _lastResults.any((r) => r == ConnectivityResult.mobile);
  bool get canDownloadMedia =>
      _state == ConnectionState.confirmedOnline && isOnWifi;
  bool get canSync => isOnline;

  Future<bool> waitUntilUsable({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    if (canSync) return true;
    final completer = Completer<bool>();
    void listener() {
      if (canSync && !completer.isCompleted) completer.complete(true);
    }

    addListener(listener);
    try {
      return await completer.future.timeout(timeout, onTimeout: () => canSync);
    } finally {
      removeListener(listener);
    }
  }

  void _init() {
    _connectivity.checkConnectivity().then(_onConnectivityChange);
    _sub = _connectivity.onConnectivityChanged.listen(_onConnectivityChange);
  }

  void _onConnectivityChange(List<ConnectivityResult> results) {
    _lastResults = results;
    final hasInterface =
        results.isNotEmpty &&
        !results.every((r) => r == ConnectivityResult.none);
    if (!hasInterface) {
      _transition(ConnectionState.offline);
      _failCount = 0;
      _probeTimer?.cancel();
      return;
    }
    // Interface is up — probe real connectivity
    _transition(ConnectionState.likelyOnline);
    _scheduleProbe();
  }

  void _scheduleProbe() {
    _probeTimer?.cancel();
    _probeTimer = Timer(const Duration(milliseconds: 500), _runProbe);
  }

  Future<void> _runProbe() async {
    final uri = _probeUri();
    if (uri == null) {
      _transition(ConnectionState.offline);
      return;
    }
    final sw = Stopwatch()..start();
    try {
      final r = await http
          .get(uri, headers: _probeHeaders())
          .timeout(_probeTimeout);
      final elapsed = sw.elapsedMilliseconds;
      if (r.statusCode == 302 || r.statusCode == 301) {
        if (r.headers['location']?.contains('captive') == true ||
            r.headers['location']?.contains('portal') == true) {
          _incrementFail(ConnectionState.captivePortal);
          return;
        }
      }
      if (r.statusCode > 0 && r.statusCode < 500) {
        final slow = elapsed > 2000;
        _confirmOnline(
          slow
              ? ConnectionState.slowConnection
              : ConnectionState.confirmedOnline,
        );
        return;
      }
      _incrementFail(ConnectionState.offline);
    } catch (_) {
      _incrementFail(ConnectionState.offline);
    }
  }

  void _confirmOnline(ConnectionState target) {
    _failCount = 0;
    _transition(target, immediate: true);
  }

  void _incrementFail(ConnectionState target) {
    _failCount++;
    if (_failCount >= 3 && target == ConnectionState.offline) {
      _transition(target, immediate: true);
      return;
    }
    _probeTimer?.cancel();
    _probeTimer = Timer(_retryDelay, _runProbe);
  }

  void _transition(ConnectionState next, {bool immediate = false}) {
    final now = DateTime.now();
    if (next == _state) return;
    if (!immediate && now.difference(_lastChange) < _debounceWindow) return;
    _lastChange = now;
    _state = next;
    notifyListeners();
  }

  Uri? _probeUri() {
    if (Env.hasSupabase) {
      return Uri.tryParse('${Env.supabaseUrl}/rest/v1/');
    }
    return Uri.tryParse('https://clients3.google.com/generate_204');
  }

  Map<String, String>? _probeHeaders() {
    if (!Env.hasSupabase) return null;
    return {
      'apikey': Env.supabasePublishableKey,
      'Authorization': 'Bearer ${Env.supabasePublishableKey}',
    };
  }

  @override
  void dispose() {
    _sub?.cancel();
    _probeTimer?.cancel();
    super.dispose();
  }
}
