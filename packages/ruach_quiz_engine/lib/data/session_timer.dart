import 'dart:async';

/// Compte à rebours pour une session de quiz.
class SessionTimer {
  Timer? _timer;

  bool get isActive => _timer != null;

  void start({required int fromSeconds, required void Function(int remaining) onTick,
      required void Function() onTimeout}) {
    cancel();
    var left = fromSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      left--;
      onTick(left);
      if (left <= 0) {
        cancel();
        onTimeout();
      }
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
