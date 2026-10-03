import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/ui/widgets/create_task_sheet.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/tasks/cubit/voice_task_cubit.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/ui/widgets/move_to_status_sheet.dart';
import 'package:client/features/tasks/ui/widgets/task_detail_sheet.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

/// Helper actions for modal sheets and navigation in KanbanScreen.
class KanbanScreenActions {
  const KanbanScreenActions._();

  static Future<(ProjectDto?, List<MemberDto>)?> loadProjectAndMembers(
    int projectId,
  ) async {
    if (projectId <= 0) return null;
    try {
      if (getIt.isRegistered<ProjectRepository>()) {
        final p = await getIt<ProjectRepository>().getProject(projectId);
        final m = getIt.isRegistered<WorkspaceRepository>()
            ? await getIt<WorkspaceRepository>().getMembers(p.workspaceId)
            : <MemberDto>[];
        return (p, m);
      }
    } catch (_) {}
    return null;
  }

  static Future<ProjectDto?> openSettings(
    BuildContext context,
    int projectId,
  ) async {
    final r = await Navigator.of(
      context,
    ).pushNamed(RouteNames.projectDetail, arguments: projectId);
    if (!context.mounted) return null;
    if (r == true) {
      Navigator.of(context).pop(true);
      return null;
    } else if (r is ProjectDto) {
      return r;
    }
    return null;
  }

  static void openCreateTask(
    BuildContext context, {
    required int projectId,
    required List<MemberDto> members,
    required KanbanCubit cubit,
    String status = 'Backlog',
  }) {
    CreateTaskSheet.show(
      context,
      projectId: projectId,
      initialStatus: status,
      members: members,
      onSubmit: (req, st) => cubit.createTask(projectId, req, initialStatus: st),
    );
  }

  static void openTaskDetail(
    BuildContext context, {
    required TaskDto task,
    required bool isArchived,
    required List<MemberDto> members,
    required KanbanCubit cubit,
  }) {
    TaskDetailSheet.show(
      context,
      task: task,
      isArchived: isArchived,
      members: members,
      onUpdate: (req) => cubit.updateTask(task.id, req),
      onStatusChange: (status) => cubit.moveTaskStatus(task.id, status),
      onDelete: () => cubit.deleteTask(task.id),
      onTaskUpdated: (t) => cubit.updateTaskInLoaded(t.id, t),
    );
  }

  static void openMoveToStatus(
    BuildContext context, {
    required TaskDto task,
    required KanbanCubit cubit,
  }) {
    MoveToStatusSheet.show(
      context,
      task: task,
      onStatusSelected: (s) => cubit.moveTaskStatus(task.id, s.toServerString()),
    );
  }

  static VoiceTaskCubit? getVoiceCubit(
    BuildContext context, [
    VoiceTaskCubit? overrideCubit,
  ]) {
    if (overrideCubit != null) return overrideCubit;
    try {
      return context.read<VoiceTaskCubit>();
    } catch (_) {
      return null;
    }
  }

  static String? getWorkspaceAccent(BuildContext context) {
    try {
      return context.watch<WorkspaceContextCubit>().state.whenOrNull(
        loaded: (_, activeWorkspace) => activeWorkspace.accentColor,
      );
    } catch (_) {
      return null;
    }
  }

  static void showError(
    BuildContext context,
    String? err,
    KanbanCubit cubit,
  ) {
    if (err == null || err.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
    cubit.clearErrorMessage();
  }
}
