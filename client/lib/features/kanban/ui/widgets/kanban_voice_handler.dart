import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/ui/widgets/voice_listening_overlay.dart';
import 'package:client/features/kanban/ui/widgets/voice_task_review_sheet.dart';
import 'package:client/features/tasks/cubit/voice_task_cubit.dart';
import 'package:client/features/tasks/cubit/voice_task_state.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';

class KanbanVoiceHandler extends StatelessWidget {
  final int projectId;
  final int workspaceId;
  final List<MemberDto> members;
  final KanbanCubit kanbanCubit;
  final Widget child;

  const KanbanVoiceHandler({
    super.key,
    required this.projectId,
    required this.workspaceId,
    required this.members,
    required this.kanbanCubit,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<VoiceTaskCubit, VoiceTaskState>(
      listener: (context, state) {
        state.maybeWhen(
          permissionDenied: (permanentlyDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Microphone permission is required for voice tasks.',
                ),
                backgroundColor: AppColors.warning,
                behavior: SnackBarBehavior.floating,
                action: permanentlyDenied
                    ? const SnackBarAction(
                        label: 'Settings',
                        textColor: Colors.white,
                        onPressed: openAppSettings,
                      )
                    : null,
              ),
            );
          },
          error: (msg) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          reviewDraft: (draft, _) {
            VoiceTaskReviewSheet.show(
              context,
              projectId: projectId,
              draft: draft,
              members: members,
              onSubmit: (req, st) =>
                  kanbanCubit.createTask(projectId, req, initialStatus: st),
            );
          },
          orElse: () {},
        );
      },
      child: Stack(
        children: [
          child,
          BlocBuilder<VoiceTaskCubit, VoiceTaskState>(
            builder: (context, state) {
              final isListening = state is VoiceTaskListening;
              final isParsing = state is VoiceTaskParsing;

              if (!isListening && !isParsing) return const SizedBox.shrink();

              final voiceCubit = context.read<VoiceTaskCubit>();
              return Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: VoiceListeningOverlay(
                  onCancel: voiceCubit.cancelListening,
                  onDone: voiceCubit.stopListening,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
