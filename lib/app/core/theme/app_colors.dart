import 'package:flutter/material.dart';

/// Central color palette for the "Midnight Gilded" theme.
///
/// A dark, cinematic base with warm gold accents used across the Bummps
/// dating app. Keep all raw color values here so screens never hardcode hex.
class AppColors {
  AppColors._();

  // Base / background surfaces
  static const Color background = Color(0xFF0E0E10);
  static const Color surface = Color(0xFF161618);
  static const Color surfaceElevated = Color(0xFF1E1E22);
  static const Color card = Color(0xFF141416);

  // Gold accents (the "gilded" side of the palette)
  static const Color gold = Color(0xFFE8B84B);
  static const Color goldLight = Color(0xFFF3D07A);
  static const Color goldDark = Color(0xFFC79A2E);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB4B4B8);
  static const Color textMuted = Color(0xFF7C7C82);
  static const Color onGold = Color(0xFF1A1400);

  // Utility
  static const Color divider = Color(0xFF2A2A2E);
  static const Color error = Color(0xFFE5484D);
  static const Color success = Color(0xFF46A758);
  static const Color inactiveDot = Color(0xFF4A4A4E);

  /// Warm gold gradient used for primary CTAs.
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [goldDark, gold, goldLight],
  );

  /// Dark scrim used over hero imagery to keep text legible.
  static const LinearGradient heroScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, background],
    stops: [0.35, 1.0],
  );
}
