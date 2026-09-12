import 'package:eduquest/shared/core/result.dart';
import 'package:eduquest/shared/security/sensitive_guard.dart';
import 'package:flutter/foundation.dart';

/// Manages screenshot protection across all content screens.
///
/// Delegates to [SensitiveGuard] (which wraps `screen_protector`)
/// and exposes a [ChangeNotifier] interface so widgets can observe state.
class ContentSecurityService extends ChangeNotifier {
  bool _active = false;

  /// Whether screenshot protection is currently enabled.
  bool get isActive => _active;

  /// Enable FLAG_SECURE (Android) + screen protection (iOS).
  Future<Result<void>> enable() async {
    if (kIsWeb) return success(null);
    try {
      await SensitiveGuard.enable();
      _active = true;
      notifyListeners();
      return success(null);
    } catch (e) {
      return failure(ContentSecurityError(message: e.toString(), cause: e));
    }
  }

  /// Disable screenshot protection.
  Future<Result<void>> disable() async {
    if (kIsWeb) return success(null);
    try {
      await SensitiveGuard.disable();
      _active = false;
      notifyListeners();
      return success(null);
    } catch (e) {
      return failure(ContentSecurityError(message: e.toString(), cause: e));
    }
  }
}
