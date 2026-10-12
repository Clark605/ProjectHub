import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:client/core/theme/app_spacing.dart';

class MetricData {
  final String label;
  final String value;
  final String trend;
  final IconData icon;
  final Color color;

  const MetricData({
    required this.label,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
  });
}

class MetricCard extends StatelessWidget {
  final MetricData data;
  final VoidCallback? onTap;

  const MetricCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.r14,
        child: Container(
          padding: AppSpacing.edgeInsetsAllLg,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.8),
            borderRadius: AppRadius.r14,
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: data.color.withValues(alpha: 0.15),
                      borderRadius: AppRadius.r8,
                    ),
                    child: Icon(data.icon, color: data.color, size: 18),
                  ),
                  AppSpacing.gapWSm,
                  Expanded(
                    child: Text(
                      data.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              AppSpacing.gapHMd,
              Text(
                data.value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              AppSpacing.gapHXs,
              Text(
                data.trend,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
