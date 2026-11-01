import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class SplashScreenController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Show splash screen for 2 seconds for smooth loading experience
    await Future.delayed(const Duration(seconds: 2));

    try {
      final auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      // If currentUser is null initially, wait for initial authState event
      user ??= await auth.authStateChanges().first.timeout(
        const Duration(milliseconds: 1500),
        onTimeout: () => auth.currentUser,
      );

      if (user != null) {
        // User is logged in; ensure profile is loaded and route to HOME
        if (Get.isRegistered<AuthService>()) {
          Get.find<AuthService>().fetchUserProfile(user.uid);
        }
        Get.offAllNamed(Routes.HOME);
      } else {
        // No session exists; route to LOGIN
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      debugPrint("Session check error: $e");
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
