import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_durations.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({super.key, required this.errorMessage, this.onDismiss});

  final String? errorMessage;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorMessage != null && errorMessage!.isNotEmpty;

    return AnimatedSwitcher(
      duration: AppDurations.medium,
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: hasError
          ? Container(
              key: ValueKey<String>(errorMessage!),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.error,
                borderRadius: AppRadius.sm,
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.pureWhite),
                  AppSpacing.gapWSm,
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.pureWhite,
                      ),
                    ),
                  ),
                  if (onDismiss != null)
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.pureWhite),
                      onPressed: onDismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
