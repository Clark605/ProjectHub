import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/core/theme/app_typography.dart';
import 'package:client/core/theme/app_theme.dart';

void main() {
  group('AppTypography Locale Resolution', () {
    test('returns Inter as default font family for en locale or null', () {
      expect(
        AppTypography.fontFamilyFor(null),
        equals(AppTypography.latinFontFamily),
      );
      expect(AppTypography.fontFamilyFor(const Locale('en')), equals('Inter'));
      expect(
        AppTypography.fallbackFor(const Locale('en')),
        contains('IBMPlexSansArabic'),
      );
    });

    test('returns IBMPlexSansArabic for ar locale with Inter fallback', () {
      expect(
        AppTypography.fontFamilyFor(const Locale('ar')),
        equals('IBMPlexSansArabic'),
      );
      expect(AppTypography.fallbackFor(const Locale('ar')), contains('Inter'));
    });

    test('getTextTheme configures correct primary and fallback families', () {
      final arabicTextTheme = AppTypography.getTextTheme(const Locale('ar'));
      expect(
        arabicTextTheme.bodyMedium?.fontFamily,
        equals('IBMPlexSansArabic'),
      );
      expect(arabicTextTheme.bodyMedium?.fontFamilyFallback, contains('Inter'));

      final englishTextTheme = AppTypography.getTextTheme(const Locale('en'));
      expect(englishTextTheme.bodyMedium?.fontFamily, equals('Inter'));
      expect(
        englishTextTheme.bodyMedium?.fontFamilyFallback,
        contains('IBMPlexSansArabic'),
      );
    });

    test('AppTheme builds dark and light theme with specified locale', () {
      final darkArabic = AppTheme.darkTheme(const Locale('ar'));
      expect(
        darkArabic.textTheme.bodyMedium?.fontFamily,
        equals('IBMPlexSansArabic'),
      );
      expect(
        darkArabic.textTheme.titleLarge?.fontFamily,
        equals('IBMPlexSansArabic'),
      );

      final lightArabic = AppTheme.lightTheme(const Locale('ar'));
      expect(
        lightArabic.textTheme.bodyMedium?.fontFamily,
        equals('IBMPlexSansArabic'),
      );
      expect(
        lightArabic.textTheme.titleLarge?.fontFamily,
        equals('IBMPlexSansArabic'),
      );
    });
  });
}
