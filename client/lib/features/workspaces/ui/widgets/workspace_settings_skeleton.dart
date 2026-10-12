import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_spacing.dart';

class WorkspaceSettingsSkeleton extends StatelessWidget {
  const WorkspaceSettingsSkeleton({super.key});

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
                _buildDetailsCardSkeleton(theme),
                AppSpacing.gapHXxl,
                _buildMembersCardSkeleton(theme),
                AppSpacing.gapHXxl,
                _buildDangerZoneSkeleton(theme),
                AppSpacing.gapHXxxl,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCardSkeleton(ThemeData theme) {
    return Container(
      padding: AppSpacing.edgeInsetsAllXl,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppRadius.r16,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone.text(words: 2),
          AppSpacing.gapHLg,
          Bone(width: double.infinity, height: 48, borderRadius: AppRadius.r12),
          AppSpacing.gapHLg,
          Bone(width: double.infinity, height: 80, borderRadius: AppRadius.r12),
          AppSpacing.gapHXl,
          Align(
            alignment: Alignment.centerRight,
            child: Bone.button(
              width: 120,
              height: 40,
              borderRadius: AppRadius.r8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersCardSkeleton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppRadius.r16,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: AppSpacing.edgeInsetsAllXl,
            child: Row(
              children: [
                Bone.text(words: 2),
                AppSpacing.gapWSm,
                Bone(width: 60, height: 20, borderRadius: AppRadius.r10),
                Spacer(),
                Bone(width: 100, height: 32, borderRadius: AppRadius.r8),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          ...List.generate(
            3,
            (index) => Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Bone.circle(size: 40),
                      AppSpacing.gapWLg,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Bone.text(words: 2),
                            AppSpacing.gapHXs,
                            Bone.text(words: 3),
                          ],
                        ),
                      ),
                      AppSpacing.gapWLg,
                      Bone(width: 50, height: 24, borderRadius: AppRadius.r6),
                    ],
                  ),
                ),
                if (index < 2)
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneSkeleton(ThemeData theme) {
    return Container(
      padding: AppSpacing.edgeInsetsAllXl,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppRadius.r16,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone.text(words: 2),
          AppSpacing.gapHSm,
          Bone.text(words: 10),
          AppSpacing.gapHLg,
          Align(
            alignment: Alignment.centerRight,
            child: Bone.button(
              width: 140,
              height: 38,
              borderRadius: AppRadius.r8,
            ),
          ),
        ],
      ),
    );
  }
}
