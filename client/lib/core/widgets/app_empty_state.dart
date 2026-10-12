import 'package:client/core/theme/app_icon_size.dart';
import 'package:flutter/material.dart';

import 'package:client/core/theme/app_spacing.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.ctaText,
    this.onCtaPressed,
  });

  final String title;
  final String? description;
  final IconData icon;
  final String? ctaText;
  final VoidCallback? onCtaPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.edgeInsetsAllXxl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppIconSize.hero,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            AppSpacing.gapHLg,
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null && description!.isNotEmpty) ...[
              AppSpacing.gapHSm,
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (ctaText != null && onCtaPressed != null) ...[
              AppSpacing.gapHXxl,
              ElevatedButton(onPressed: onCtaPressed, child: Text(ctaText!)),
            ],
          ],
        ),
      ),
    );
  }
}
