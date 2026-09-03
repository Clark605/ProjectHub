import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:client/core/theme/app_colors.dart';

class WorkspaceSettingsSkeleton extends StatelessWidget {
  const WorkspaceSettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
                _buildDetailsCardSkeleton(),
                const SizedBox(height: 24),
                _buildMembersCardSkeleton(),
                const SizedBox(height: 24),
                _buildDangerZoneSkeleton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
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
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Bone.button(
              width: 120,
              height: 40,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersCardSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Bone.text(words: 2, fontSize: 16),
                const SizedBox(width: 8),
                Bone(
                  width: 60,
                  height: 20,
                  borderRadius: BorderRadius.circular(10),
                ),
                const Spacer(),
                Bone(
                  width: 100,
                  height: 32,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ...List.generate(
            3,
            (index) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Bone.circle(size: 40),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Bone.text(words: 2, fontSize: 14),
                            SizedBox(height: 4),
                            Bone.text(words: 3, fontSize: 12),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Bone(
                        width: 50,
                        height: 24,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ),
                if (index < 2)
                  const Divider(height: 1, color: AppColors.border),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Bone.text(words: 2, fontSize: 16),
          const SizedBox(height: 8),
          const Bone.text(words: 10, fontSize: 13),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Bone.button(
              width: 140,
              height: 38,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}
