import 'package:flutter/material.dart';

class AppColors {
  // --- Primary Brand Colors (From Praarambh Logo) ---
  static const Color primaryBlueLight = Color(0xFF0B5394);
  static const Color primaryBlueDark = Color(0xFF1976D2);

  static const Color primaryOrangeLight = Color(0xFFE68619);
  static const Color primaryOrangeDark = Color(0xFFB36717);

  // --- Background/Surfaces ---
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);

  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // --- Text Colors ---
  static const Color textMainLight = Color(0xFF2D3436);
  static const Color textMainDark = Color(0xFFF8F9FA);

  static const Color textSecondaryLight = Color(0xFF636E72);
  static const Color textSecondaryDark = Color(0xFFB2BEC3);

  static const Color textMutedLight = Color(0xFFB2BEC3);
  static const Color textMutedDark = Color(0xFF636E72);

  // --- Component Colors ---
  static const Color borderLight = Color(0xFFE9ECEF);
  static const Color borderDark = Color(0xFF2D3436);

  // --- Helper Methods ---
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color getPrimaryBlue(BuildContext context) => isDark(context) ? primaryBlueDark : primaryBlueLight;

  static Color getPrimaryOrange(BuildContext context) => isDark(context) ? primaryOrangeDark : primaryOrangeLight;

  static Color getScaffoldColor(BuildContext context) => isDark(context) ? backgroundDark : backgroundLight;

  static Color getCardColor(BuildContext context) => isDark(context) ? surfaceDark : surfaceLight;

  static Color getTextColor(BuildContext context) => isDark(context) ? textMainDark : textMainLight;

  static Color getSecondaryTextColor(BuildContext context) => isDark(context) ? textSecondaryDark : textSecondaryLight;

  static Color getMutedColor(BuildContext context) => isDark(context) ? textMutedDark : textMutedLight;

  static Color getBorderColor(BuildContext context) => isDark(context) ? borderDark : borderLight;
}