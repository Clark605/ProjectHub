import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/kanban/ui/widgets/voice_task_fab.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanFab extends StatelessWidget {
  const KanbanFab({
    super.key,
    required this.isArchived,
    required this.onPressed,
    this.onVoicePressed,
    this.isListening = false,
  });

  final bool isArchived;
  final VoidCallback onPressed;
  final VoidCallback? onVoicePressed;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    if (isArchived) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onVoicePressed != null) ...[
          VoiceTaskFab(
            isArchived: isArchived,
            isListening: isListening,
            onPressed: onVoicePressed!,
          ),
          const SizedBox(width: 12),
        ],
        FloatingActionButton.extended(
          onPressed: onPressed,
          backgroundColor: AppColors.electricVioletContainer,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            l10n?.newTask ?? 'New Task',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
