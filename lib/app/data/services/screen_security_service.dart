import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

/// Pure Dart service managing OS-level screen protection (Anti-Screenshot & Anti-Screen Recording)
/// via the flutter_windowmanager plugin.
class ScreenSecurityService {
  /// Set secure mode:
  /// [enable] = true  -> Blocks screenshots, screen recording, and app switcher previews (FLAG_SECURE ON)
  /// [enable] = false -> Allows screenshots (FLAG_SECURE OFF)
  static Future<bool> setSecureMode(bool enable) async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        if (enable) {
          await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
        } else {
          await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
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
