import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/tasks/cubit/voice_task_cubit.dart';
import 'package:client/features/tasks/cubit/voice_task_state.dart';

class VoiceListeningOverlay extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onDone;

  const VoiceListeningOverlay({
    super.key,
    required this.onCancel,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceTaskCubit, VoiceTaskState>(
      builder: (context, state) {
        final isParsing = state is VoiceTaskParsing;
        final recognizedText = state is VoiceTaskListening
            ? state.recognizedText
            : (state is VoiceTaskParsing ? state.fullText : '');

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: AppColors.electricViolet.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.electricVioletContainer.withValues(
                  alpha: 0.25,
                ),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildPulseOrb(isParsing),
              const SizedBox(height: 16),
              Text(
                isParsing ? 'Structuring task with AI...' : 'Listening...',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(
                  minHeight: 56,
                  maxHeight: 100,
                ),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    recognizedText.isEmpty
                        ? 'Speak naturally (e.g. "Add an urgent task to review metrics due tomorrow")'
                        : recognizedText,
                    style: TextStyle(
                      fontSize: 14,
                      color: recognizedText.isEmpty
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                      fontStyle: recognizedText.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (isParsing)
                const LinearProgressIndicator(
                  color: AppColors.electricVioletContainer,
                  backgroundColor: AppColors.surfaceContainerLow,
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onCancel,
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: onDone,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Done Speaking'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.electricVioletContainer,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPulseOrb(bool isParsing) {
    return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                isParsing ? AppColors.skyBlue : AppColors.electricViolet,
                isParsing
                    ? AppColors.skyBlueContainer
                    : AppColors.electricVioletContainer,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color:
                    (isParsing
                            ? AppColors.skyBlueContainer
                            : AppColors.electricVioletContainer)
                        .withValues(alpha: 0.6),
                blurRadius: 18,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(
            isParsing ? Icons.auto_awesome : Icons.mic_rounded,
            color: Colors.white,
            size: 32,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1.12, 1.12),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
  }
}
