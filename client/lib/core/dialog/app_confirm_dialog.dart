import 'package:client/core/dialog/app_dialog.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

/// Shows a standardized confirmation dialog across the application.
Future<bool> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
  bool isDestructive = false,
  bool showCancelButton = true,
}) async {
  final result = await showAppDialog<bool>(
    context: context,
    builder: (ctx) => AppConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDestructive: isDestructive,
      showCancelButton: showCancelButton,
    ),
  );
  return result ?? false;
}

class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.isDestructive = false,
    this.showCancelButton = true,
    this.onConfirm,
  });

  final String title;
  final String message;
  final String? confirmLabel;
  final String? cancelLabel;
  final bool isDestructive;
  final bool showCancelButton;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveConfirmLabel =
        confirmLabel ?? (isDestructive ? 'Delete' : 'Confirm');
    final effectiveCancelLabel = cancelLabel ?? 'Cancel';

    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.kRadiusLg),
      backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: isDestructive
              ? AppColors.error
              : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
        ),
      ),
      content: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDark
              ? AppColors.textSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
      actions: [
        if (showCancelButton)
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              effectiveCancelLabel,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        FilledButton(
          onPressed: () {
            if (onConfirm != null) {
              onConfirm!();
            } else {
              Navigator.of(context).pop(true);
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: isDestructive
                ? AppColors.error
                : (isDark ? AppColors.primary : AppColors.primaryContainer),
            foregroundColor: isDestructive
                ? Colors.white
                : (isDark ? AppColors.textOnPrimary : Colors.white),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.kRadiusSm,
            ),
          ),
          child: Text(effectiveConfirmLabel),
        ),
      ],
    );
  }
}
