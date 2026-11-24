import 'package:flutter/material.dart';

/// Material 3 Typography Scale for Taskora.
/// Engineered for legibility, proportional hierarchy, and responsive text scaling.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Roboto'; // Clean system default

  static TextTheme textTheme(Color primaryText, Color secondaryText) {
    return TextTheme(
      // Display
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 40.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.15,
        color: primaryText,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.2,
        color: primaryText,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.25,
        color: primaryText,
      ),

      // Headline
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.3,
        color: primaryText,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.35,
        color: primaryText,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.4,
        color: primaryText,
      ),

      // Title
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        height: 1.4,
        color: primaryText,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.45,
        color: primaryText,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.45,
        color: primaryText,
      ),

      // Body
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
        color: primaryText,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.5,
        color: secondaryText,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        height: 1.4,
        color: secondaryText,
      ),

      // Label
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.35,
        color: primaryText,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        height: 1.35,
        color: secondaryText,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 10.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.3,
        color: secondaryText,
      ),
    );
  }
}
