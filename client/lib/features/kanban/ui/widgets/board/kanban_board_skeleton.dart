import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class KanbanBoardSkeleton extends StatelessWidget {
  const KanbanBoardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          if (isMobile) {
            return _buildMobileSkeleton(context);
          }
          return _buildDesktopSkeleton(context);
        },
      ),
    );
  }

  Widget _buildMobileSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Bone(
                    width: index == 0 ? 92 : 82,
                    height: 32,
                    borderRadius: AppRadius.r20,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, _) => _buildTaskCardSkeleton(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: AppRadius.r16,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildColumnHeaderSkeleton(context),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, _) => _buildTaskCardSkeleton(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildColumnHeaderSkeleton(BuildContext context) {
    return const Row(
      children: [
        Bone.circle(size: 10),
        SizedBox(width: 8),
        Flexible(child: Bone.text(words: 2)),
        SizedBox(width: 8),
        Bone(
          width: 24,
          height: 18,
          borderRadius: BorderRadius.all(Radius.circular(9)),
        ),
        Spacer(),
        Bone.icon(size: 18),
      ],
    );
  }

  Widget _buildTaskCardSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppRadius.r12,
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: const ClipRRect(
        borderRadius: AppRadius.r12,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              width: 4,
              child: Bone(
                width: 4,
                height: double.infinity,
                borderRadius: BorderRadius.zero,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Bone.text(words: 3)),
                      SizedBox(width: 8),
                      Bone.icon(size: 18),
                    ],
                  ),
                  SizedBox(height: 8),
                  Bone(width: 52, height: 18, borderRadius: AppRadius.r10),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Bone(
                              width: 44,
                              height: 16,
                              borderRadius: AppRadius.r6,
                            ),
                            Bone(
                              width: 38,
                              height: 16,
                              borderRadius: AppRadius.r6,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 6),
                      Bone.circle(size: 22),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
