import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:client/core/theme/app_colors.dart';

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.onTap,
    this.delayMs = 400,
  });

  final String promptText;
  final String actionText;
  final VoidCallback onTap;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          promptText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark
                ? AppColors.textSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.electricViolet,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(
      duration: 400.ms,
      delay: Duration(milliseconds: delayMs),
    );
  }
}
