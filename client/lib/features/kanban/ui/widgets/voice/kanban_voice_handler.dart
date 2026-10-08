import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/app_snackbar.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/ui/widgets/voice/voice_listening_overlay.dart';
import 'package:client/features/kanban/ui/widgets/voice/voice_task_review_sheet.dart';
import 'package:client/features/tasks/cubit/voice_task_cubit.dart';
import 'package:client/features/tasks/cubit/voice_task_state.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    return BlocListener<VoiceTaskCubit, VoiceTaskState>(
      listener: (context, state) {
        state.maybeWhen(
          permissionDenied: (permanentlyDenied) {
            showAppSnackBar(
              context,
              l10n?.voiceTaskMicPermissionRequired ??
                  'Microphone permission is required for voice tasks.',
              backgroundColor: AppColors.warning,
              action: permanentlyDenied
                  ? SnackBarAction(
                      label: l10n?.voiceTaskSettings ?? 'Settings',
                      textColor: Colors.white,
                      onPressed: openAppSettings,
                    )
                  : null,
            );
          },
          error: (msg) {
            showAppErrorSnackBar(context, msg);
          },
          reviewDraft: (draft, _) {
            VoiceTaskReviewSheet.show(
              context,
              projectId: projectId,
              draft: draft,
              members: members,
              onSubmit: (req, st) async {
                await kanbanCubit.createTask(projectId, req, initialStatus: st);
                if (context.mounted) {
                  context.read<VoiceTaskCubit>().reset();
                }
              },
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
              return Positioned.fill(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: voiceCubit.cancelListening,
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: VoiceListeningOverlay(
                        onCancel: voiceCubit.cancelListening,
                        onDone: voiceCubit.stopListening,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
