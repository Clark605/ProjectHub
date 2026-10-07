import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.userId,
    this.size = 32,
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.border,
  });

  final String name;
  final String? userId;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final BoxBorder? border;

  String get _initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].characters.take(1).toString().toUpperCase();
    }
    return '${parts[0].characters.take(1)}${parts[1].characters.take(1)}'
        .toUpperCase();
  }

  Color _resolveBackgroundColor(BuildContext context) {
    if (backgroundColor != null) return backgroundColor!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final seed = (userId != null && userId!.isNotEmpty) ? userId! : name;
    if (seed.isEmpty) return AppColors.primaryContainer;
    final hash = seed.codeUnits.fold<int>(0, (prev, elem) => (prev * 31 + elem) & 0x7FFFFFFF);
    final baseColor = AppColors.avatarPalette[hash % AppColors.avatarPalette.length];
    return isDark ? baseColor.withValues(alpha: 0.28) : baseColor.withValues(alpha: 0.18);
  }

  Color _resolveTextColor(BuildContext context) {
    if (textColor != null) return textColor!;
    if (textStyle?.color != null) return textStyle!.color!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final seed = (userId != null && userId!.isNotEmpty) ? userId! : name;
    if (seed.isEmpty) return AppColors.textOnPrimary;
    final hash = seed.codeUnits.fold<int>(0, (prev, elem) => (prev * 31 + elem) & 0x7FFFFFFF);
    final baseColor = AppColors.avatarPalette[hash % AppColors.avatarPalette.length];
    return isDark ? AppColors.textPrimary : baseColor;
  }

  @override
  Widget build(BuildContext context) {
    final bg = _resolveBackgroundColor(context);
    final fg = _resolveTextColor(context);

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
        style: textStyle ??
            TextStyle(
              color: fg,
              fontSize: size * 0.4,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
