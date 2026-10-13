import 'package:client/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Semantic colors ThemeExtension providing adaptive colors without manual `isDark` branching.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color subtleSurface;
  final Color subtleSurfaceStrong;
  final Color subtleBorder;
  final Color textSecondary;
  final double badgeAlpha;
  final double badgeEmphasisAlpha;
  final double avatarAlpha;
  final bool avatarUsesTextPrimary;

  const AppColorsExtension({
    required this.subtleSurface,
    required this.subtleSurfaceStrong,
    required this.subtleBorder,
    required this.textSecondary,
    required this.badgeAlpha,
    required this.badgeEmphasisAlpha,
    required this.avatarAlpha,
    required this.avatarUsesTextPrimary,
  });

  /// Light theme color role instance.
  static final AppColorsExtension light = AppColorsExtension(
    subtleSurface: AppColors.pureBlack.withValues(alpha: 0.05),
    subtleSurfaceStrong: AppColors.pureBlack.withValues(alpha: 0.06),
    subtleBorder: AppColors.lightBorder,
    textSecondary: AppColors.lightTextSecondary,
    badgeAlpha: 0.12,
    badgeEmphasisAlpha: 0.15,
    avatarAlpha: 0.18,
    avatarUsesTextPrimary: false,
  );

  /// Dark theme color role instance.
  static final AppColorsExtension dark = AppColorsExtension(
    subtleSurface: AppColors.pureWhite.withValues(alpha: 0.06),
    subtleSurfaceStrong: AppColors.pureWhite.withValues(alpha: 0.10),
    subtleBorder: AppColors.border,
    textSecondary: AppColors.textSecondary,
    badgeAlpha: 0.20,
    badgeEmphasisAlpha: 0.28,
    avatarAlpha: 0.28,
    avatarUsesTextPrimary: true,
  );

  /// Resolves the tinted background fill for status, priority, and due-date badges.
  Color badgeBackground(Color color, {bool emphasis = false}) {
    return color.withValues(alpha: emphasis ? badgeEmphasisAlpha : badgeAlpha);
  }

  /// Resolves the background fill for initials and avatar circles.
  Color avatarBackground(Color base) {
    return base.withValues(alpha: avatarAlpha);
  }

  /// Resolves the text color for avatar initials.
  Color avatarTextColor(Color base) {
    return avatarUsesTextPrimary ? AppColors.textPrimary : base;
  }

  @override
  AppColorsExtension copyWith({
    Color? subtleSurface,
    Color? subtleSurfaceStrong,
    Color? subtleBorder,
    Color? textSecondary,
    double? badgeAlpha,
    double? badgeEmphasisAlpha,
    double? avatarAlpha,
    bool? avatarUsesTextPrimary,
  }) {
    return AppColorsExtension(
      subtleSurface: subtleSurface ?? this.subtleSurface,
      subtleSurfaceStrong: subtleSurfaceStrong ?? this.subtleSurfaceStrong,
      subtleBorder: subtleBorder ?? this.subtleBorder,
      textSecondary: textSecondary ?? this.textSecondary,
      badgeAlpha: badgeAlpha ?? this.badgeAlpha,
      badgeEmphasisAlpha: badgeEmphasisAlpha ?? this.badgeEmphasisAlpha,
      avatarAlpha: avatarAlpha ?? this.avatarAlpha,
      avatarUsesTextPrimary:
          avatarUsesTextPrimary ?? this.avatarUsesTextPrimary,
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
      badgeEmphasisAlpha:
          badgeEmphasisAlpha + (other.badgeEmphasisAlpha - badgeEmphasisAlpha) * t,
      avatarAlpha: avatarAlpha + (other.avatarAlpha - avatarAlpha) * t,
      avatarUsesTextPrimary:
          t < 0.5 ? avatarUsesTextPrimary : other.avatarUsesTextPrimary,
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
          badgeAlpha == other.badgeAlpha &&
          badgeEmphasisAlpha == other.badgeEmphasisAlpha &&
          avatarAlpha == other.avatarAlpha &&
          avatarUsesTextPrimary == other.avatarUsesTextPrimary;

  @override
  int get hashCode => Object.hash(
    subtleSurface,
    subtleSurfaceStrong,
    subtleBorder,
    textSecondary,
    badgeAlpha,
    badgeEmphasisAlpha,
    avatarAlpha,
    avatarUsesTextPrimary,
  );
}
