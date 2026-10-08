import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:client/core/theme/app_colors.dart';

class VoiceTaskFab extends StatelessWidget {
  final bool isArchived;
  final bool isListening;
  final VoidCallback onPressed;

  const VoiceTaskFab({
    super.key,
    required this.isArchived,
    this.isListening = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isArchived) return const SizedBox.shrink();

    final fab = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isListening
              ? [AppColors.priorityUrgent, AppColors.electricVioletContainer]
              : [AppColors.electricVioletContainer, AppColors.skyBlueContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (isListening
                        ? AppColors.priorityUrgent
                        : AppColors.electricVioletContainer)
                    .withValues(alpha: isListening ? 0.6 : 0.35),
            blurRadius: isListening ? 16 : 8,
            spreadRadius: isListening ? 2 : 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Icon(
            isListening ? Icons.stop_rounded : Icons.mic_rounded,
            color: AppColors.pureWhite,
            size: 24,
          ),
        ),
      ),
    );

    if (isListening) {
      return fab
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.12, 1.12),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
    }

    return fab;
  }
}
