import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const String latinFontFamily = 'Inter';
  static const String arabicFontFamily = 'IBMPlexSansArabic';

  /// Default font family for backward compatibility
  static const String fontFamily = latinFontFamily;

  static String fontFamilyFor(Locale? locale) =>
      locale?.languageCode == 'ar' ? arabicFontFamily : latinFontFamily;

  static List<String> fallbackFor(Locale? locale) =>
      locale?.languageCode == 'ar'
      ? const [latinFontFamily]
      : const [arabicFontFamily];

  /// Default text theme (with Arabic fallback)
  static TextTheme get textTheme => getTextTheme();

  /// Builds a locale-aware [TextTheme] with primary font and fallback.
  static TextTheme getTextTheme([Locale? locale]) {
    final primary = fontFamilyFor(locale);
    final fallback = fallbackFor(locale);

    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: primary,
        fontFamilyFallback: fallback,
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(
        fontFamily: primary,
        fontFamilyFallback: fallback,
        fontSize: 45,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        fontFamily: primary,
        fontFamilyFallback: fallback,
        fontSize: 36,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        fontFamily: primary,
        fontFamilyFallback: fallback,
        fontSize: 32,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontFamily: primary,
        fontFamilyFallback: fallback,
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontFamily: primary,
        fontFamilyFallback: fallback,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontFamily: primary,
        fontFamilyFallback: fallback,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontFamily: primary,
        fontFamilyFallback: fallback,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontFamily: primary,
        fontFamilyFallback: fallback,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontFamily: primary,
        fontFamilyFallback: fallback,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: primary,
        fontFamilyFallback: fallback,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontFamily: primary,
        fontFamilyFallback: fallback,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      labelLarge: TextStyle(
        fontFamily: primary,
        fontFamilyFallback: fallback,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontFamily: primary,
        fontFamilyFallback: fallback,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontFamily: primary,
        fontFamilyFallback: fallback,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}
