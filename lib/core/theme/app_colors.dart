import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF0056D2);
  static const Color primaryLight = Color(0xFF0075FF);

  // Background Colors
  static const Color backgroundLight = Colors.white;
  static const Color white = Color(0xFF1385F6);

  // Text Colors
  static const Color textDark = Colors.black;
  static const Color textGrey = Colors.grey;
  
  // UI Element Colors
  static const Color borderGrey = Color(0xFFE0E0E0); // Colors.grey.shade300
  static const Color inputFill = Color(0xFFFAFAFA); // Colors.grey.shade50
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryLight, primary],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundLight, white],
  );
}
