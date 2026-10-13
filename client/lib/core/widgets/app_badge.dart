import 'package:flutter/material.dart';

import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/theme/app_typography.dart';

/// Standardized compact badge for task priorities, due dates, and inline tags.
class AppBadge extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color color;
  final Color? backgroundColor;
  final bool isEmphasis;

  const AppBadge({
    super.key,
    this.icon,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.isEmphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedBackground =
        backgroundColor ??
        context.appColors.badgeBackground(color, emphasis: isEmphasis);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: resolvedBackground,
        borderRadius: AppRadius.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppIconSize.xxs, color: color),
            AppSpacing.gapWXxs,
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.badge.copyWith(
                color: color,
                fontWeight: isEmphasis ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
