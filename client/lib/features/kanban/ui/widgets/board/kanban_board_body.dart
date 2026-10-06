import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/app_error_state.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/kanban/ui/widgets/board/kanban_board_skeleton.dart';
import 'package:client/features/kanban/ui/widgets/board/kanban_desktop_board.dart';
import 'package:client/features/kanban/ui/widgets/board/kanban_empty_state.dart';
import 'package:client/features/kanban/ui/widgets/board/kanban_mobile_board.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanBoardBody extends StatelessWidget {
  final KanbanState state;
  final int projectId;
  final bool isArchived;
  final String? wsAccent;
  final PageController? pageController;
  final int? currentColumnIndex;
  final ValueChanged<int>? onColumnChanged;
  final VoidCallback onRetry;
  final VoidCallback onClearFilters;
  final ValueChanged<TaskStatus>? onAddTask;
  final ValueChanged<TaskDto>? onTaskTap;
  final ValueChanged<TaskDto>? onTaskMove;
  final ValueChanged<TaskDto>? onTaskDelete;
  final ValueChanged<TagDto>? onTagTap;

  const KanbanBoardBody({
    super.key,
    required this.state,
    required this.projectId,
    required this.isArchived,
    this.wsAccent,
    this.pageController,
    this.currentColumnIndex,
    this.onColumnChanged,
    required this.onRetry,
    required this.onClearFilters,
    this.onAddTask,
    this.onTaskTap,
    this.onTaskMove,
    this.onTaskDelete,
    this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return state.when(
      initial: () => const KanbanBoardSkeleton(),
      loading: () => const KanbanBoardSkeleton(),
      error: (message) => AppErrorState(
        errorMessage: message,
        onRetry: onRetry,
      ),
      empty: (projId, arch, err) => KanbanEmptyState(
        isArchived: arch,
        onCreateTask: onAddTask != null
            ? () => onAddTask!(TaskStatus.backlog)
            : null,
      ),
      loaded: (projId, tasks, allTasks, arch, filter, err) {
        final hasActiveFilter =
            (filter.search != null && filter.search!.isNotEmpty) ||
            (filter.priority != null && filter.priority!.isNotEmpty) ||
            (filter.assigneeId != null && filter.assigneeId!.isNotEmpty) ||
            filter.tagId != null;
        if (tasks.isEmpty && hasActiveFilter) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.filter_list_off_rounded,
                    size: 44,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n?.noTasksMatchFilters ??
                        'No tasks match active filters',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: onClearFilters,
                    child: Text(l10n?.clearFilters ?? 'Clear Filters'),
                  ),
                ],
              ),
            ),
          );
        }

        final tasksByStatus = state.tasksByStatus;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;
            if (isMobile) {
              return KanbanMobileBoard(
                pageController: pageController,
                currentColumnIndex: currentColumnIndex,
                onColumnChanged: onColumnChanged,
                tasksByStatus: tasksByStatus,
                isArchived: arch,
                wsAccent: wsAccent,
                onAddTask: onAddTask,
                onTaskTap: onTaskTap,
                onTaskMove: onTaskMove,
                onTaskDelete: onTaskDelete,
                onTagTap: onTagTap,
              );
            }
            return KanbanDesktopBoard(
              tasksByStatus: tasksByStatus,
              isArchived: arch,
              availableHeight: constraints.maxHeight,
              wsAccent: wsAccent,
              onAddTask: onAddTask,
              onTaskTap: onTaskTap,
              onTaskMove: onTaskMove,
              onTaskDelete: onTaskDelete,
              onTagTap: onTagTap,
            );
          },
        );
      },
    );
  }
}
