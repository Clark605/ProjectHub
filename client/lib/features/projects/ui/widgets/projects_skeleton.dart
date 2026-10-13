import 'package:client/core/theme/app_radius.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProjectsSkeleton extends StatelessWidget {
  const ProjectsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);
    final theme = Theme.of(context);

    Widget buildCard() {
      return Container(
        padding: AppSpacing.edgeInsetsAllLg,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: AppRadius.lg,
          border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Bone.text(words: 3)),
                AppSpacing.gapWSm,
                Bone(width: 60, height: 22, borderRadius: AppRadius.xl),
              ],
            ),
            AppSpacing.gapHXs,
            const Bone.text(words: 10),
            AppSpacing.gapHMd,
            // Progress Bar & Task Count
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Bone.text(words: 4),
                Bone(width: 28, height: 14, borderRadius: AppRadius.xs),
              ],
            ),
            AppSpacing.gapHXs,
            const Bone(
              height: 5,
              width: double.infinity,
              borderRadius: AppRadius.xs,
            ),
            AppSpacing.gapHSm,
            // Member avatars stack
            Row(
              children: [
                for (int i = 0; i < 3; i++)
                  Align(
                    widthFactor: 0.75,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surfaceContainerLow,
                          width: 1.5,
                        ),
                      ),
                      child: const Bone.circle(size: 24),
                    ),
                  ),
              ],
            ),
            AppSpacing.gapHSm,
            const Divider(height: 1, thickness: 1),
            AppSpacing.gapHSm,
            const Row(
              children: [
                Bone(width: 80, height: 14, borderRadius: AppRadius.xs),
                Spacer(),
                Bone(width: 70, height: 14, borderRadius: AppRadius.xs),
              ],
            ),
          ],
        ),
      );
    }

    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.zero,
          AppSpacing.xxl,
          AppSpacing.fabClearance,
        ),
        child: (!isDesktop && !isTablet)
            ? ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 4,
                separatorBuilder: (_, _) => AppSpacing.gapHLg,
                itemBuilder: (_, _) => buildCard(),
              )
            : GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : 2,
                  crossAxisSpacing: AppSpacing.lg,
                  mainAxisSpacing: AppSpacing.lg,
                  mainAxisExtent: 240,
                ),
                itemCount: 6,
                itemBuilder: (_, _) => buildCard(),
              ),
      ),
    );
  }
}
