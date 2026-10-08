import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/tasks/cubit/voice_task_cubit.dart';
import 'package:client/features/tasks/cubit/voice_task_state.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class VoiceListeningOverlay extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onDone;
  final bool animate;

  const VoiceListeningOverlay({
    super.key,
    required this.onCancel,
    required this.onDone,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<VoiceTaskCubit, VoiceTaskState>(
      builder: (context, state) {
        final isParsing = state is VoiceTaskParsing;
        final recognizedText = state is VoiceTaskListening
            ? state.recognizedText
            : (state is VoiceTaskParsing ? state.fullText : '');

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceContainerHigh.withValues(alpha: 0.95)
                : theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark
                  ? AppColors.electricViolet.withValues(alpha: 0.3)
                  : AppColors.electricVioletContainer.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.electricVioletContainer.withValues(
                  alpha: isDark ? 0.25 : 0.15,
                ),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                GestureDetector(
                  onTap: isParsing ? null : onDone,
                  child: _buildPulseOrb(isParsing),
                ),
                const SizedBox(height: 16),
                Text(
                  isParsing
                      ? (l10n?.voiceTaskStructuring ??
                            'Structuring task with AI...')
                      : (l10n?.voiceTaskListening ?? 'Listening...'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
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
                    color: isDark
                        ? AppColors.surfaceContainerLowest
                        : theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      recognizedText.isEmpty
                          ? (l10n?.voiceTaskPlaceholder ??
                                'Speak naturally (e.g. "Add an urgent task to review metrics due tomorrow")')
                          : recognizedText,
                      style: TextStyle(
                        fontSize: 14,
                        color: recognizedText.isEmpty
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                        fontStyle: recognizedText.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (isParsing)
                  LinearProgressIndicator(
                    color: AppColors.electricVioletContainer,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: onCancel,
                        child: Text(
                          l10n?.voiceTaskCancel ?? 'Cancel',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: onDone,
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(l10n?.voiceTaskDone ?? 'Done Speaking'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricVioletContainer,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 42),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulseOrb(bool isParsing) {
    final orb = Container(
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
    );

    if (!animate) return orb;

    return orb
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1.12, 1.12),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
  }
}
