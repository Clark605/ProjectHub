import 'package:client/core/theme/app_avatar_size.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.size = AppAvatarSize.md,
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.border,
  }) : _isUnassigned = false;

  const AppAvatar.unassigned({
    super.key,
    this.size = AppAvatarSize.sm,
    this.backgroundColor,
    this.textColor,
    this.border,
  }) : name = '',
       textStyle = null,
       _isUnassigned = true;

  final String name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final BoxBorder? border;
  final bool _isUnassigned;

  double get _unassignedIconSize {
    if (size <= AppAvatarSize.xs) return AppIconSize.xxs;
    if (size <= AppAvatarSize.sm) return AppIconSize.xxs;
    if (size <= AppAvatarSize.compact) return AppIconSize.xs;
    if (size <= AppAvatarSize.md) return AppIconSize.sm;
    if (size <= AppAvatarSize.lg) return AppIconSize.lg;
    return AppIconSize.xl;
  }

  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].characters.take(1).toString().toUpperCase();
    }
    return '${parts[0].characters.take(1)}${parts[1].characters.take(1)}'
        .toUpperCase();
  }

  String get _normalizedSeed => name.trim().toLowerCase();

  Color get _baseColor {
    final seed = _normalizedSeed;
    if (seed.isEmpty) return AppColors.primary;
    final hash = seed.codeUnits.fold<int>(
      0,
      (prev, elem) => (prev * 31 + elem) & 0x7FFFFFFF,
    );
    return AppColors.avatarPalette[hash % AppColors.avatarPalette.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isUnassigned) {
      final bg = backgroundColor ?? AppColors.subtleSurfaceStrong(isDark);
      final fg = textColor ?? AppColors.textSecondaryColor(isDark);

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: border,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.person_outline_rounded,
          size: _unassignedIconSize,
          color: fg,
        ),
      );
    }

    final base = _baseColor;
    final bg =
        backgroundColor ??
        (isDark ? base.withValues(alpha: 0.28) : base.withValues(alpha: 0.18));
    final fg =
        textColor ??
        (textStyle?.color ?? (isDark ? AppColors.textPrimary : base));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: AppTypography.avatarStyle(
          size: size,
          color: fg,
        ).merge(textStyle),
      ),
    );
  }
}
