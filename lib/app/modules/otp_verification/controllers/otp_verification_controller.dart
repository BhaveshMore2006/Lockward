import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class OtpVerificationController extends GetxController {
  final otpController = TextEditingController();
  final isLoading = false.obs;
  final defaultOtp = '1234';

  final AuthService _authService = Get.find<AuthService>();

  String userName = '';
  String userEmail = '';
  String userPhone = '';
  String userPassword = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is List && args.length >= 4) {
      userName = args[0].toString();
      userEmail = args[1].toString();
      userPhone = args[2].toString();
      userPassword = args[3].toString();
    } else {
      debugPrint("OTP ERROR: Get.arguments is missing or invalid: $args");
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }

  void verifyOtp() async {
    if (otpController.text.trim() == defaultOtp) {
      isLoading.value = true;
      
      if (userEmail.isEmpty) {
        isLoading.value = false;
        Get.snackbar(
          'Data Error', 
          'User data is missing. Please restart from Sign Up.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      try {
        bool success = await _authService.register(
          name: userName,
          email: userEmail,
          phone: userPhone,
          password: userPassword,
        );

        isLoading.value = false;
        if (success) {
          Get.offAllNamed(Routes.HOME);
        }
      } catch (e) {
        isLoading.value = false;
        Get.snackbar(
          'Firebase Error', 
          'Failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } else {
      Get.snackbar(
        'Invalid OTP',
        'Please enter the default OTP: 1234',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
