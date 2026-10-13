import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';

/// Semantic colors ThemeExtension providing adaptive colors without manual `isDark` branching.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color subtleSurface;
  final Color subtleSurfaceStrong;
  final Color subtleBorder;
  final Color textSecondary;
  final double badgeAlpha;

  const AppColorsExtension({
    required this.subtleSurface,
    required this.subtleSurfaceStrong,
    required this.subtleBorder,
    required this.textSecondary,
    required this.badgeAlpha,
  });

  /// Light theme color role instance.
  static const AppColorsExtension light = AppColorsExtension(
    subtleSurface: Color(0x0D000000), // pureBlack with 0.05 alpha
    subtleSurfaceStrong: Color(0x0F000000), // pureBlack with 0.06 alpha
    subtleBorder: AppColors.lightBorder,
    textSecondary: AppColors.lightTextSecondary,
    badgeAlpha: 0.12,
  );

  /// Dark theme color role instance.
  static const AppColorsExtension dark = AppColorsExtension(
    subtleSurface: Color(0x1AFFFFFF), // pureWhite with 0.1 alpha
    subtleSurfaceStrong: Color(0x1AFFFFFF), // pureWhite with 0.1 alpha
    subtleBorder: Color(0x1AFFFFFF), // pureWhite with 0.1 alpha
    textSecondary: AppColors.textSecondary,
    badgeAlpha: 0.2,
  );

  /// Resolves the tinted background fill for status, priority, and due-date badges.
  Color badgeBackground(Color color, {bool emphasis = false}) {
    return color.withValues(alpha: emphasis ? 0.15 : badgeAlpha);
  }

  @override
  AppColorsExtension copyWith({
    Color? subtleSurface,
    Color? subtleSurfaceStrong,
    Color? subtleBorder,
    Color? textSecondary,
    double? badgeAlpha,
  }) {
    return AppColorsExtension(
      subtleSurface: subtleSurface ?? this.subtleSurface,
      subtleSurfaceStrong: subtleSurfaceStrong ?? this.subtleSurfaceStrong,
      subtleBorder: subtleBorder ?? this.subtleBorder,
      textSecondary: textSecondary ?? this.textSecondary,
      badgeAlpha: badgeAlpha ?? this.badgeAlpha,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      subtleSurface:
          Color.lerp(subtleSurface, other.subtleSurface, t) ?? subtleSurface,
      subtleSurfaceStrong:
          Color.lerp(subtleSurfaceStrong, other.subtleSurfaceStrong, t) ??
          subtleSurfaceStrong,
      subtleBorder:
          Color.lerp(subtleBorder, other.subtleBorder, t) ?? subtleBorder,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      badgeAlpha: badgeAlpha + (other.badgeAlpha - badgeAlpha) * t,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppColorsExtension &&
          runtimeType == other.runtimeType &&
          subtleSurface == other.subtleSurface &&
          subtleSurfaceStrong == other.subtleSurfaceStrong &&
          subtleBorder == other.subtleBorder &&
          textSecondary == other.textSecondary &&
          badgeAlpha == other.badgeAlpha;

  @override
  int get hashCode => Object.hash(
        subtleSurface,
        subtleSurfaceStrong,
        subtleBorder,
        textSecondary,
        badgeAlpha,
      );
}
