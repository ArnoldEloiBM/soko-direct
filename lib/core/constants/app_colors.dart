import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  //main colors (green/brown, fits the farm theme)
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color earthBrown = Color(0xFF6D4C41);
  static const Color sandBeige = Color(0xFFF5F0E6);

  //for messages/status
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFD32F2F);

  //light mode
  static const Color lightBg = Colors.white;
  static const Color lightSurface = sandBeige;
  static const Color lightText = Color(0xFF1B1B1B);

  //dark mode
  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Color(0xFFECECEC);
}
