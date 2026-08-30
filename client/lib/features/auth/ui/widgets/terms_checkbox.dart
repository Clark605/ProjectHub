import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: AppColors.electricViolet,
              ),
            ),
            const SizedBox(width: 10),
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
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Text(
              l10n.termsRequired,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
