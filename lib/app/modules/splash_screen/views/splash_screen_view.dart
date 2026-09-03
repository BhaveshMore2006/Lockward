import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/splash_screen_controller.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
        child: Image.asset(
          'assets/images/icon1.png',
          width: 200,
          height: 200,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.security,
              size: 150,
              color: AppColors.primary,
            );
          },
        ),
      ),
      ),
    );
  }
}


