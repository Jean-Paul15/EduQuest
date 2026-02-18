import 'package:flutter/foundation.dart';
import 'package:eduquest/features/learning/data/learning_security_repository.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SensitiveGuard {
  static int _depth = 0;

  static Future<void> enable() async {
    if (kIsWeb) return;
    _depth += 1;
    if (_depth > 1) return;
    final policy = await LearningSecurityRepository().load();
    if (!policy.captureAllowed) {
      await ScreenProtector.preventScreenshotOn();
      await ScreenProtector.protectDataLeakageWithBlur();
    } else {
      await ScreenProtector.preventScreenshotOff();
      await ScreenProtector.protectDataLeakageOff();
    }
    if (policy.keepAwake) {
      await WakelockPlus.enable();
    }
  }

  static Future<void> disable() async {
    if (kIsWeb) return;
    if (_depth > 0) _depth -= 1;
    if (_depth > 0) return;
    await ScreenProtector.preventScreenshotOff();
    await ScreenProtector.protectDataLeakageOff();
    await WakelockPlus.disable();
  }
}
