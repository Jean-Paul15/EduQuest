import 'package:eduquest/shared/sync/offline_state_notifier.dart';
import 'package:flutter/foundation.dart';

abstract class OfflineViewState implements Listenable {
  bool get isOffline;
}

class LocatorOfflineViewState extends ChangeNotifier
    implements OfflineViewState {
  LocatorOfflineViewState(this._source);
  final OfflineStateNotifier _source;

  @override
  bool get isOffline => _source.isOffline;

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _source.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _source.removeListener(listener);
    super.removeListener(listener);
  }
}
