import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:client/core/utils/responsive_layout.dart';
import 'package:client/core/theme/app_spacing.dart';

class ProjectsSkeleton extends StatelessWidget {
  const ProjectsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);
    final theme = Theme.of(context);

    Widget buildCard() {
      return Container(
        padding: AppSpacing.edgeInsetsAll16,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: AppRadius.r16,
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
                AppSpacing.gapW8,
                Bone(width: 60, height: 22, borderRadius: AppRadius.r20),
              ],
            ),
            AppSpacing.gapH6,
            const Bone.text(words: 10),
            AppSpacing.gapH12,
            // Progress Bar & Task Count
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Bone.text(words: 4),
                Bone(width: 28, height: 14, borderRadius: AppRadius.r3),
              ],
            ),
            AppSpacing.gapH6,
            const Bone(
              height: 5,
              width: double.infinity,
              borderRadius: AppRadius.r3,
            ),
            AppSpacing.gapH10,
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
            AppSpacing.gapH10,
            const Divider(height: 1, thickness: 1),
            AppSpacing.gapH8,
            const Row(
              children: [
                Bone(width: 80, height: 14, borderRadius: AppRadius.r3),
                Spacer(),
                Bone(width: 70, height: 14, borderRadius: AppRadius.r3),
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
          AppSpacing.s80,
        ),
        child: (!isDesktop && !isTablet)
            ? ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 4,
                separatorBuilder: (_, _) => AppSpacing.gapH16,
                itemBuilder: (_, _) => buildCard(),
              )
            : GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 240,
                ),
                itemCount: 6,
                itemBuilder: (_, _) => buildCard(),
              ),
      ),
    );
  }
}
