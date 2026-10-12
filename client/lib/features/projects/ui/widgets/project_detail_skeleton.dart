import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:client/core/theme/app_spacing.dart';

class ProjectDetailSkeleton extends StatelessWidget {
  const ProjectDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xxl,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: AppSpacing.edgeInsetsAllXl,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: AppRadius.lg,
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Bone.text(words: 2),
                      AppSpacing.gapHLg,
                      Bone(
                        width: double.infinity,
                        height: 48,
                        borderRadius: AppRadius.md,
                      ),
                      AppSpacing.gapHLg,
                      Bone(
                        width: double.infinity,
                        height: 80,
                        borderRadius: AppRadius.md,
                      ),
                      AppSpacing.gapHLg,
                      Bone(
                        width: double.infinity,
                        height: 48,
                        borderRadius: AppRadius.md,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
