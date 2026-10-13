import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class TermsCheckbox extends StatelessWidget {
  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.hasError,
    this.onTermsPressed,
    this.onPrivacyPressed,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool hasError;
  final VoidCallback? onTermsPressed;
  final VoidCallback? onPrivacyPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: AppSpacing.xxl,
              width: AppSpacing.xxl,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.xs),
                activeColor: AppColors.electricViolet,
              ),
            ),
            AppSpacing.gapWSm,
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: l10n.termsAndPrivacyPrefix),
                    TextSpan(
                      text: l10n.termsOfService,
                      style: const TextStyle(
                        color: AppColors.skyBlue,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = onTermsPressed ?? () {},
                    ),
                    TextSpan(text: l10n.and),
                    TextSpan(
                      text: l10n.privacyPolicy,
                      style: const TextStyle(
                        color: AppColors.skyBlue,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = onPrivacyPressed ?? () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
        if (hasError) ...[
          AppSpacing.gapHXs,
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xxxl),
            child: Text(
              l10n.termsRequired,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
