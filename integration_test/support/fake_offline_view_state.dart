import 'package:eduquest/shared/sync/offline_view_state.dart';
import 'package:flutter/foundation.dart';

class FakeOfflineViewState extends ChangeNotifier implements OfflineViewState {
  FakeOfflineViewState({bool isOffline = false}) : _isOffline = isOffline;
  bool _isOffline;

  @override
  bool get isOffline => _isOffline;

  void setOffline(bool value) {
    _isOffline = value;
    notifyListeners();
  }
}
