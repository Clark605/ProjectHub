import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class VoiceTaskReviewHeader extends StatelessWidget {
  final VoidCallback onClose;

  const VoiceTaskReviewHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final badgeColor = isDark
        ? AppColors.electricViolet
        : AppColors.electricVioletContainer;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.electricVioletContainer.withValues(
              alpha: isDark ? 0.2 : 0.12,
            ),
            borderRadius: AppRadius.r16,
            border: Border.all(
              color: isDark
                  ? AppColors.electricVioletContainer
                  : AppColors.electricVioletContainer.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 14, color: badgeColor),
              const SizedBox(width: 4),
              Text(
                l10n.voiceTaskAiDraftPreview,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: badgeColor,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close_rounded),
          color: theme.colorScheme.onSurfaceVariant,
          onPressed: onClose,
        ),
      ],
    );
  }
}
