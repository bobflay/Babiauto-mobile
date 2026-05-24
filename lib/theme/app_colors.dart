import 'package:flutter/material.dart';

/// Babiauto palette — ported verbatim from the design `styles.css` `:root` block.
class AppColors {
  AppColors._();

  static const orange = Color(0xFFF39423);
  static const orangeDeep = Color(0xFFE67A0C);
  static const orangeSoft = Color(0xFFFDE5C7);

  static const ink = Color(0xFF1A1612);
  static const ink2 = Color(0xFF3D362E);
  static const ink3 = Color(0xFF6B6358);

  static const paper = Color(0xFFFFFBF5);
  static const paper2 = Color(0xFFF5EFE5);

  /// Warm off-white used as the map land tone / app background on map screens.
  static const mapLand = Color(0xFFF4EEDF);
  static const mapLandDark = Color(0xFF1F1B17);

  // rgba(26, 22, 18, x)
  static const line = Color(0x141A1612); // 0.08
  static const line2 = Color(0x241A1612); // 0.14

  // oklch approximations (sRGB), matching the design fallbacks.
  static const green = Color(0xFF34A853);
  static const lagoon = Color(0xFF4A90E2);
  static const rose = Color(0xFFD75A48);

  static Color inkA(double opacity) => ink.withValues(alpha: opacity);
  static Color whiteA(double opacity) => Colors.white.withValues(alpha: opacity);
}
