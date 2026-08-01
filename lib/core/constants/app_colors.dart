import 'package:flutter/material.dart';

/// Shared colors matching the assignment UI mockups.
class AppColors {
  AppColors._();

  // main colors (green/brown, fits the farm theme)
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color earthBrown = Color(0xFF6D4C41);
  static const Color sandBeige = Color(0xFFF5F0E6);

  // for messages/status
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFD32F2F);

  // light mode
  static const Color lightBg = Colors.white;
  static const Color lightSurface = sandBeige;
  static const Color lightText = Color(0xFF1B1B1B);

  // dark mode
  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Color(0xFFECECEC);

  // listings — market price + status badges (Arnold's listings feature)
  static const marketPriceBg = Color(0xFFE8F5E9);
  static const marketPriceBorder = Color(0xFF2D6A4F);
  static const badgeActiveBg = Color(0xFFD8F3DC);
  static const badgeActiveText = Color(0xFF2D6A4F);
  static const badgeOffersBg = Color(0xFFFFF3E0);
  static const badgeOffersText = Color(0xFFE65100);
  static const badgeSoldBg = Color(0xFFEDE7F6);
  static const badgeSoldText = Color(0xFF5E35B1);
  static const cardBorder = Color(0xFFE0E0E0);
  static const subtitleGrey = Color(0xFF757575);
  static const captionGrey = Color(0xFF9E9E9E);
}
