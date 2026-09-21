import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:client/core/utils/responsive_layout.dart';

class ProjectsSkeleton extends StatelessWidget {
  const ProjectsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final columns = isDesktop
        ? 3
        : (ResponsiveLayout.isTablet(context) ? 2 : 1);

    final theme = Theme.of(context);

    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 175,
          ),
          itemCount: 6,
          itemBuilder: (context, index) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Bone.text(words: 2, fontSize: 16),
                    Bone(width: 60, height: 22),
                  ],
                ),
                SizedBox(height: 12),
                Bone.text(words: 8, fontSize: 13),
                Spacer(),
                Divider(height: 1),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Bone.text(words: 1, fontSize: 12),
                    Bone.text(words: 1, fontSize: 12),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
