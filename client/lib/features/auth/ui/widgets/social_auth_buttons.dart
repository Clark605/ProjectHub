import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/l10n/generated/app_localizations.dart';

import 'package:client/features/auth/ui/widgets/github_logo_painter.dart';
import 'package:client/features/auth/ui/widgets/google_logo_painter.dart';

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
    final l10n = AppLocalizations.of(context)!;

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : AppColors.lightBorder;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: borderColor, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.orContinueWith,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ),
            Expanded(child: Divider(color: borderColor, thickness: 1)),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                iconWidget: const CustomPaint(
                  painter: GoogleLogoPainter(),
                  size: Size(20, 20),
                ),
                label: 'Google',
                onPressed: onGooglePressed ?? () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SocialButton(
                iconWidget: CustomPaint(
                  painter: GithubLogoPainter(
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  size: const Size(20, 20),
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
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.lightBorder;
    final textColor = isDark
        ? AppColors.textPrimary
        : AppColors.lightTextPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(width: 10),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
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

