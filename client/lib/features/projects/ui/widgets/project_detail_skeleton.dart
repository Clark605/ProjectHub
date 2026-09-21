import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProjectDetailSkeleton extends StatelessWidget {
  const ProjectDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Bone.text(words: 2, fontSize: 18),
                      const SizedBox(height: 16),
                      Bone(
                        width: double.infinity,
                        height: 48,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(height: 16),
                      Bone(
                        width: double.infinity,
                        height: 80,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(height: 16),
                      Bone(
                        width: double.infinity,
                        height: 48,
                        borderRadius: BorderRadius.circular(12),
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
