import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';

/// Reusable geometric status indicator dot (presence, status badge).
class StatusDot extends StatelessWidget {
  const StatusDot({
    super.key,
    this.color = AppColors.success,
    this.size = 8.0,
    this.borderColor,
    this.borderWidth = 1.5,
  });

  final Color color;
  final double size;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
    );
  }
}
