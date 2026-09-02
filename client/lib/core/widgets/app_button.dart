import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
    this.borderRadius = 12.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.primary
                  ? AppColors.primary
                  : AppColors.electricViolet,
            ),
          )
        : Row(
            mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    final radius = BorderRadius.circular(borderRadius);

    final buttonStyle = switch (variant) {
      AppButtonVariant.primary => ElevatedButton.styleFrom(
        backgroundColor: AppColors.electricViolet,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        minimumSize: isExpanded
            ? const Size(double.infinity, 52)
            : const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      AppButtonVariant.secondary => ElevatedButton.styleFrom(
        backgroundColor: isDark
            ? AppColors.surfaceContainer
            : AppColors.lightSurfaceContainer,
        foregroundColor: isDark
            ? AppColors.textPrimary
            : AppColors.lightTextPrimary,
        elevation: 0,
        minimumSize: isExpanded
            ? const Size(double.infinity, 52)
            : const Size(0, 52),
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: isDark ? AppColors.border : AppColors.lightBorder,
          ),
        ),
      ),
      AppButtonVariant.outline => OutlinedButton.styleFrom(
        foregroundColor: AppColors.electricViolet,
        minimumSize: isExpanded
            ? const Size(double.infinity, 52)
            : const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: radius),
        side: const BorderSide(color: AppColors.electricViolet),
      ),
      AppButtonVariant.text => TextButton.styleFrom(
        foregroundColor: AppColors.electricViolet,
        minimumSize: isExpanded
            ? const Size(double.infinity, 52)
            : const Size(0, 52),
      ),
    };

    return switch (variant) {
      AppButtonVariant.outline => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: child,
      ),
      _ => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: child,
      ),
    };
  }
}
