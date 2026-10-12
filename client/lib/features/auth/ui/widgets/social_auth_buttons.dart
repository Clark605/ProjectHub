import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';

import 'package:client/features/auth/ui/widgets/github_logo.dart';
import 'package:client/features/auth/ui/widgets/google_logo.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class SocialAuthSection extends StatelessWidget {
  const SocialAuthSection({
    super.key,
    this.onGooglePressed,
    this.onGithubPressed,
  });

  final VoidCallback? onGooglePressed;
  final VoidCallback? onGithubPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    final borderColor = AppColors.subtleBorder(isDark);
    final textSecondary = AppColors.textSecondaryColor(isDark);

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: borderColor, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                l10n.orContinueWith,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(child: Divider(color: borderColor, thickness: 1)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                iconWidget: const GoogleLogo(size: 20),
                label: 'Google',
                onPressed: onGooglePressed ?? () {},
              ),
            ),
            AppSpacing.gapWMd,
            Expanded(
              child: _SocialButton(
                iconWidget: GithubLogo(
                  size: 20,
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.lightTextPrimary,
                ),
                label: 'GitHub',
                onPressed: onGithubPressed ?? () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.iconWidget,
    required this.label,
    required this.onPressed,
  });

  final Widget iconWidget;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurface;
    final borderColor = isDark
        ? AppColors.pureWhite.withValues(alpha: 0.12)
        : AppColors.lightBorder;
    final textColor = isDark
        ? AppColors.textPrimary
        : AppColors.lightTextPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.md,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.md,
            border: Border.all(color: borderColor, width: 1.1),
            boxShadow: [
              BoxShadow(
                color: AppColors.pureBlack.withValues(
                  alpha: isDark ? 0.2 : 0.04,
                ),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              AppSpacing.gapWSm,
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
