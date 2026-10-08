import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:client/core/utils/responsive_layout.dart';

class ProjectsSkeleton extends StatelessWidget {
  const ProjectsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);
    final theme = Theme.of(context);

    Widget buildCard() {
      return Container(
        padding: const EdgeInsets.all(16),
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
                SizedBox(width: 8),
                Bone(width: 60, height: 22, borderRadius: AppRadius.r20),
              ],
            ),
            const SizedBox(height: 6),
            const Bone.text(words: 10),
            const SizedBox(height: 12),
            // Progress Bar & Task Count
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Bone.text(words: 4),
                Bone(width: 28, height: 14, borderRadius: AppRadius.r3),
              ],
            ),
            const SizedBox(height: 6),
            const Bone(
              height: 5,
              width: double.infinity,
              borderRadius: AppRadius.r3,
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 8),
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
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
        child: (!isDesktop && !isTablet)
            ? ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 4,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
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
