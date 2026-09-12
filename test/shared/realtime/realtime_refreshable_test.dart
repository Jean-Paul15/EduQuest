import 'package:eduquest/shared/realtime/cache_invalidation_bus.dart';
import 'package:eduquest/shared/realtime/cache_signal.dart';
import 'package:eduquest/shared/realtime/realtime_refreshable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Probe extends StatefulWidget {
  const _Probe();
  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> with RealtimeRefreshable<_Probe> {
  int reloads = 0;

  @override
  List<String> get realtimeNamespaces => const ['chapter'];

  @override
  Future<void> reloadFromRealtime() async => reloads++;

  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('recharge sur le bon namespace, ignore les autres, reagit au reset',
      (tester) async {
    CacheInvalidationBus.instance
        .setScope(const ScopeContext(seriesId: 'S', levelId: 'L'));
    await tester.pumpWidget(const MaterialApp(home: _Probe()));
    final state = tester.state<_ProbeState>(find.byType(_Probe));

    Future<void> deliver(CacheSignal s) async {
      CacheInvalidationBus.instance.emit(s);
      await CacheInvalidationBus.instance.flushNow(); // bypass debounce du bus
      await tester.pump(const Duration(milliseconds: 300)); // debounce du mixin
    }

    await deliver(const CacheSignal(hint: 'contests'));
    expect(state.reloads, 0, reason: 'namespace hub -> ignore par un ecran chapter');

    await deliver(const CacheSignal(hint: 'resources', ref: {'chapter_id': 'CH'}));
    expect(state.reloads, 1);

    await deliver(const CacheSignal(hint: '*'));
    expect(state.reloads, 2, reason: 'reset scope -> tous les ecrans rechargent');
  });
}
