import 'package:flutter/foundation.dart';

class ScopeRefreshBus {
  static final ValueNotifier<int> _rev = ValueNotifier<int>(0);

  static ValueListenable<int> get listenable => _rev;

  static void bump() {
    _rev.value = _rev.value + 1;
  }
}
