import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:client/core/theme/app_colors.dart';

class ShellPresenceIndicator extends StatelessWidget {
  const ShellPresenceIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.3, 1.3),
                duration: 1200.ms,
              ),
          const SizedBox(width: 8),
          const Text(
            '3 Online',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          _buildMiniAvatar('AK', AppColors.electricViolet),
          const SizedBox(width: 4),
          _buildMiniAvatar('SR', AppColors.skyBlue),
          const SizedBox(width: 4),
          _buildMiniAvatar('DM', AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildMiniAvatar(String text, Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.25),
        border: Border.all(color: color, width: 1),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 9,
          ),
        ),
      ),
    );
  }
}
