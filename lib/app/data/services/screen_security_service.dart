import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:screen_protector/screen_protector.dart';

/// Pure Dart service managing OS-level screen protection (Anti-Screenshot & Anti-Screen Recording)
/// via the modern screen_protector plugin (compatible with Flutter 3.27+ and Android AGP 8+).
class ScreenSecurityService {
  /// Set secure mode:
  /// [enable] = true  -> Blocks screenshots, screen recording, and app switcher previews (FLAG_SECURE ON)
  /// [enable] = false -> Allows screenshots (FLAG_SECURE OFF)
  static Future<bool> setSecureMode(bool enable) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        if (enable) {
          await ScreenProtector.preventScreenshotOn();
        } else {
          await ScreenProtector.preventScreenshotOff();
        }
        return true;
      } catch (e) {
        debugPrint('ScreenSecurityService error: $e');
        return false;
      }
    }
    return true;
  }
}
