import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/dark_theme.dart';
import 'package:client/core/theme/light_theme.dart';

void main() {
  group('AppColorsExtension', () {
    test('light instance provides expected tokens', () {
      const ext = AppColorsExtension.light;
      expect(ext.subtleSurface, equals(const Color(0x0D000000)));
      expect(ext.subtleSurfaceStrong, equals(const Color(0x0F000000)));
      expect(ext.subtleBorder, equals(AppColors.lightBorder));
      expect(ext.textSecondary, equals(AppColors.lightTextSecondary));
      expect(ext.badgeAlpha, equals(0.12));
    });

    test('dark instance provides expected tokens', () {
      const ext = AppColorsExtension.dark;
      expect(ext.subtleSurface, equals(const Color(0x1AFFFFFF)));
      expect(ext.subtleSurfaceStrong, equals(const Color(0x1AFFFFFF)));
      expect(ext.subtleBorder, equals(const Color(0x1AFFFFFF)));
      expect(ext.textSecondary, equals(AppColors.textSecondary));
      expect(ext.badgeAlpha, equals(0.2));
    });

    test('badgeBackground respects alpha and emphasis', () {
      const ext = AppColorsExtension.light;
      const testColor = Color(0xFF6366F1);

      final normal = ext.badgeBackground(testColor);
      final emphasized = ext.badgeBackground(testColor, emphasis: true);

      expect(normal, equals(testColor.withValues(alpha: 0.12)));
      expect(emphasized, equals(testColor.withValues(alpha: 0.15)));
    });

    test('copyWith updates specified fields', () {
      const ext = AppColorsExtension.light;
      final copied = ext.copyWith(subtleSurface: Colors.red, badgeAlpha: 0.5);

      expect(copied.subtleSurface, equals(Colors.red));
      expect(copied.badgeAlpha, equals(0.5));
      expect(copied.subtleBorder, equals(ext.subtleBorder));
      expect(copied.textSecondary, equals(ext.textSecondary));
    });

    test('lerp interpolates between extensions', () {
      const light = AppColorsExtension.light;
      const dark = AppColorsExtension.dark;

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
  });
}
