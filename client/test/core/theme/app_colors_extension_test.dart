import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/dark_theme.dart';
import 'package:client/core/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColorsExtension', () {
    test('light instance provides expected tokens', () {
      final ext = AppColorsExtension.light;
      expect(ext.subtleSurface, equals(AppColors.pureBlack.withValues(alpha: 0.05)));
      expect(ext.subtleSurfaceStrong, equals(AppColors.pureBlack.withValues(alpha: 0.06)));
      expect(ext.subtleBorder, equals(AppColors.lightBorder));
      expect(ext.textSecondary, equals(AppColors.lightTextSecondary));
      expect(ext.badgeAlpha, equals(0.12));
      expect(ext.badgeEmphasisAlpha, equals(0.15));
      expect(ext.avatarAlpha, equals(0.18));
      expect(ext.avatarUsesTextPrimary, isFalse);
    });

    test('dark instance provides expected tokens', () {
      final ext = AppColorsExtension.dark;
      expect(ext.subtleSurface, equals(AppColors.pureWhite.withValues(alpha: 0.06)));
      expect(ext.subtleSurfaceStrong, equals(AppColors.pureWhite.withValues(alpha: 0.10)));
      expect(ext.subtleBorder, equals(AppColors.border));
      expect(ext.textSecondary, equals(AppColors.textSecondary));
      expect(ext.badgeAlpha, equals(0.2));
      expect(ext.badgeEmphasisAlpha, equals(0.28));
      expect(ext.avatarAlpha, equals(0.28));
      expect(ext.avatarUsesTextPrimary, isTrue);
    });

    test('badgeBackground respects alpha and emphasis', () {
      final ext = AppColorsExtension.light;
      const testColor = Color(0xFF6366F1);

      final normal = ext.badgeBackground(testColor);
      final emphasized = ext.badgeBackground(testColor, emphasis: true);

      expect(normal, equals(testColor.withValues(alpha: 0.12)));
      expect(emphasized, equals(testColor.withValues(alpha: 0.15)));
    });

    test('avatarBackground and avatarTextColor adapt to theme', () {
      final light = AppColorsExtension.light;
      final dark = AppColorsExtension.dark;
      const testColor = Color(0xFF6366F1);

      expect(light.avatarBackground(testColor), equals(testColor.withValues(alpha: 0.18)));
      expect(light.avatarTextColor(testColor), equals(testColor));

      expect(dark.avatarBackground(testColor), equals(testColor.withValues(alpha: 0.28)));
      expect(dark.avatarTextColor(testColor), equals(AppColors.textPrimary));
    });

    test('copyWith updates specified fields', () {
      final ext = AppColorsExtension.light;
      final copied = ext.copyWith(subtleSurface: Colors.red, badgeAlpha: 0.5);

      expect(copied.subtleSurface, equals(Colors.red));
      expect(copied.badgeAlpha, equals(0.5));
      expect(copied.subtleBorder, equals(ext.subtleBorder));
      expect(copied.textSecondary, equals(ext.textSecondary));
    });

    test('lerp interpolates between extensions', () {
      final light = AppColorsExtension.light;
      final dark = AppColorsExtension.dark;

      final mid = light.lerp(dark, 0.5);

      expect(mid.badgeAlpha, closeTo(0.16, 0.001));
      expect(
        mid.subtleBorder,
        equals(Color.lerp(light.subtleBorder, dark.subtleBorder, 0.5)),
      );
    });

    test('registered in buildLightTheme and buildDarkTheme', () {
      final lightTheme = buildLightTheme();
      final darkTheme = buildDarkTheme();

      expect(
        lightTheme.extension<AppColorsExtension>(),
        equals(AppColorsExtension.light),
      );
      expect(
        darkTheme.extension<AppColorsExtension>(),
        equals(AppColorsExtension.dark),
      );
    });

    testWidgets('context.appColors resolves extension from theme', (
      tester,
    ) async {
      late AppColorsExtension resolvedLight;
      late AppColorsExtension resolvedDark;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: Builder(
            builder: (context) {
              resolvedLight = context.appColors;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolvedLight, equals(AppColorsExtension.light));

      await tester.pumpWidget(
        MaterialApp(
          theme: buildDarkTheme(),
          home: Builder(
            builder: (context) {
              resolvedDark = context.appColors;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(resolvedDark, equals(AppColorsExtension.dark));
    });

    testWidgets(
      'context.appColors asserts when AppColorsExtension is missing',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Builder(
              builder: (context) {
                expect(
                  () => context.appColors,
                  throwsAssertionError,
                );
                return const SizedBox();
              },
            ),
          ),
        );
      },
    );
  });
}
