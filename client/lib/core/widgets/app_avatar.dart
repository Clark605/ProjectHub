import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.size = 32,
    this.backgroundColor,
    this.textStyle,
  });

  final String name;
  final double size;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  String get _initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].characters.take(1).toString().toUpperCase();
    }
    return '${parts[0].characters.take(1)}${parts[1].characters.take(1)}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: textStyle ?? TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
