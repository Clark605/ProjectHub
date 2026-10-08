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
                    borderRadius: BorderRadius.circular(20),
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
                borderRadius: BorderRadius.circular(16),
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
    return Row(
      children: [
        const Bone.circle(size: 10),
        const SizedBox(width: 8),
        const Flexible(child: Bone.text(words: 2, fontSize: 14)),
        const SizedBox(width: 8),
        Bone(width: 24, height: 18, borderRadius: BorderRadius.circular(9)),
        const Spacer(),
        const Bone.icon(size: 18),
      ],
    );
  }

  Widget _buildTaskCardSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            const Positioned(
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
              padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Bone.text(words: 3, fontSize: 14),
                      ),
                      SizedBox(width: 8),
                      Bone.icon(size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Bone(
                    width: 52,
                    height: 18,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 12),
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
                              borderRadius: BorderRadius.circular(6),
                            ),
                            Bone(
                              width: 38,
                              height: 16,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Bone.circle(size: 22),
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
