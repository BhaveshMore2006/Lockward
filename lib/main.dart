import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_preview/device_preview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/data/services/auth_service.dart';
import 'app/data/services/vault_service.dart';
import 'app/data/services/screen_security_service.dart';
import 'app/data/services/session_security_service.dart';
import 'core/theme/app_colors.dart';
import 'firebase_options.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenSecurityService.setSecureMode(true);

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("dotenv load warning: $e");
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stack) {
    debugPrint("Firebase init error: $e\n$stack");
  }

  try {
    // Initialize our Authentication Service globally
    Get.put(AuthService(), permanent: true);
  } catch (e, stack) {
    debugPrint("AuthService init error: $e\n$stack");
  }

  try {
    // Initialize VaultService globally
    Get.put(VaultService(), permanent: true);
  } catch (e, stack) {
    debugPrint("VaultService init error: $e\n$stack");
  }

  try {
    // Initialize SessionSecurityService globally (Inactivity & Background auto-lock)
    Get.put(SessionSecurityService(), permanent: true);
  } catch (e, stack) {
    debugPrint("SessionSecurityService init error: $e\n$stack");
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const LockwardApp(),
    ),
  );
}

class LockwardApp extends StatelessWidget {
  const LockwardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      title: "Lockward",

      // Device Preview settings with global Inactivity Touch Watchdog
      builder: (context, child) {
        final previewChild = DevicePreview.appBuilder(context, child);
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) {
            if (Get.isRegistered<SessionSecurityService>()) {
              SessionSecurityService.to.recordUserActivity();
            }
          },
          child: previewChild,
        );
      },
      locale: DevicePreview.locale(context),

      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.white,
        textTheme: GoogleFonts.poppinsTextTheme(), // Unified text format
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: const TextStyle(color: AppColors.textGrey),
        ),
      ),
    );
  }
}
