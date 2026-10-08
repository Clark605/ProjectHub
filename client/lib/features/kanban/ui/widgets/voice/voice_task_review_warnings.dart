import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_radius.dart';

class VoiceTaskReviewWarnings extends StatelessWidget {
  final List<String> warnings;

  const VoiceTaskReviewWarnings({super.key, required this.warnings});

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final warningColor = isDark ? AppColors.warning : AppColors.warningLight;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: warningColor.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: AppRadius.kRadiusSm,
        border: Border.all(
          color: warningColor.withValues(alpha: isDark ? 0.4 : 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: warnings
            .map(
              (w) => Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: warningColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      w,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: warningColor,
                      ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
