import 'package:client/core/theme/app_icon_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBrandLogo = true,
  });

  final String title;
  final String subtitle;
  final bool showBrandLogo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    return Column(
      children: [
        if (showBrandLogo) ...[
          // Brand Logo Row: [Hub Icon] Project Hub
          Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.hub_rounded,
                    size: AppIconSize.xl,
                    color: AppColors.electricViolet,
                  ),
                  AppSpacing.gapWSm,
                  Text(
                    l10n.appTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              )
              .animate()
              .scale(duration: 400.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 400.ms),
          AppSpacing.gapHXxl,
        ],

        // Main Title
        Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: isDark
                    ? AppColors.textPrimary
                    : AppColors.lightTextPrimary,
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
        AppSpacing.gapHSm,

        // Subtitle
        Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
                height: 1.4,
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }
}
