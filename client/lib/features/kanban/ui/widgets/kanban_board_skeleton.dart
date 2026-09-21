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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColumnHeaderSkeleton(context),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
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
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.6),
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
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Bone(
                width: 56,
                height: 20,
                borderRadius: BorderRadius.circular(6),
              ),
              const Bone.icon(size: 16),
            ],
          ),
          const SizedBox(height: 10),
          const Bone.text(words: 4, fontSize: 14),
          const SizedBox(height: 6),
          const Bone.text(words: 8, fontSize: 12),
          const SizedBox(height: 12),
          Row(
            children: [
              Bone(
                width: 32,
                height: 16,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(width: 6),
              Bone(
                width: 38,
                height: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Bone.circle(size: 18),
              Bone(
                width: 48,
                height: 12,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
