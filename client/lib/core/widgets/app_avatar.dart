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

  Color get _baseColor {
    // Seed deterministically from normalized name first so avatars for the same person
    // always match whether or not userId was provided at a particular call site.
    final seed = name.trim().isNotEmpty
        ? name.trim().toLowerCase()
        : (userId ?? '').trim().toLowerCase();
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
    final base = _baseColor;
    final bg = backgroundColor ??
        (isDark
            ? base.withValues(alpha: 0.28)
            : base.withValues(alpha: 0.18));
    final fg = textColor ??
        (textStyle?.color ??
            (isDark ? AppColors.textPrimary : base));

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

