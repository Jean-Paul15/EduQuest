import 'package:flutter/foundation.dart';
import 'package:screen_protector/screen_protector.dart';

class SensitiveGuard {
  static Future<void> enable() async {
    if (kIsWeb) return;
    await ScreenProtector.preventScreenshotOn();
    await ScreenProtector.protectDataLeakageWithBlur();
  }

  static Future<void> disable() async {
    if (kIsWeb) return;
    await ScreenProtector.preventScreenshotOff();
    await ScreenProtector.protectDataLeakageOff();
  }
}

