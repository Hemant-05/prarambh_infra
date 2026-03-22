import 'package:flutter/material.dart';

class AppColors {
  // --- Primary Brand Colors (From Praarambh Logo) ---
  static const Color primaryBlueLight = Color(0xFF0B5394);
  static const Color primaryBlueDark = Color(0xFF1976D2);

  static const Color primaryOrangeLight = Color(0xFFE68619);
  static const Color primaryOrangeDark = Color(0xFFB36717);

  // --- Background Colors ---
  static const Color backgroundLight = Color(0xFFFAFAFA); // grey[50]
  static const Color backgroundDark = Color(0xFF121212);

  // --- Card/Surface Colors ---
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E); // grey[900]

  // --- Text Colors ---
  static const Color textMainLight = Colors.black87;
  static const Color textMainDark = Colors.white;
  static const Color textMutedLight = Colors.grey;
  static const Color textMutedDark = Colors.white54;

  // --- Borders & Dividers ---
  static const Color borderLight = Color(0xFFE0E0E0); // grey[300]
  static const Color borderDark = Color(0xFF424242); // grey[700]

  // --- Helper Methods to get correct color based on theme ---
  static Color getPrimaryBlue(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? primaryBlueDark
        : primaryBlueLight;
  }

  static Color getPrimaryOrange(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? primaryOrangeDark
        : primaryOrangeLight;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cardDark
        : cardLight;
  }
}