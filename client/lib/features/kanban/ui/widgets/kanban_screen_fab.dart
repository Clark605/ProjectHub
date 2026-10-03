import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/features/kanban/ui/widgets/kanban_fab.dart';
import 'package:client/features/tasks/cubit/voice_task_cubit.dart';
import 'package:client/features/tasks/cubit/voice_task_state.dart';

class KanbanScreenFab extends StatelessWidget {
  final bool isArchived;
  final VoiceTaskCubit? voiceCubit;
  final int projectId;
  final int workspaceId;
  final VoidCallback onOpenCreateTask;

  const KanbanScreenFab({
    super.key,
    required this.isArchived,
    required this.voiceCubit,
    required this.projectId,
    required this.workspaceId,
    required this.onOpenCreateTask,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = voiceCubit;
    if (cubit == null) {
      return KanbanFab(
        isArchived: isArchived,
        onPressed: onOpenCreateTask,
      );
    }
    return BlocBuilder<VoiceTaskCubit, VoiceTaskState>(
      bloc: cubit,
      builder: (context, voiceState) {
        final isVoiceActive =
            voiceState is VoiceTaskListening || voiceState is VoiceTaskParsing;
        if (isVoiceActive) return const SizedBox.shrink();

        return KanbanFab(
          isArchived: isArchived,
          isListening: false,
          onPressed: onOpenCreateTask,
          onVoicePressed: () {
            cubit.toggleListening(
              projectId: projectId,
              workspaceId: workspaceId,
            );
          },
        );
      },
    );
  }
}
