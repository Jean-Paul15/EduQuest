import 'package:eduquest/shared/network/connectivity_oracle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('likelyOnline is usable for silent queue draining', () {
    final oracle = ConnectivityOracle.test(ConnectionState.likelyOnline);
    expect(oracle.canSync, true);
    oracle.dispose();
  });

  test('offline blocks queue draining', () {
    final oracle = ConnectivityOracle.test(ConnectionState.offline);
    expect(oracle.canSync, false);
    oracle.dispose();
  });
}
