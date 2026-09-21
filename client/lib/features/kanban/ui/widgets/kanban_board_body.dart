import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/kanban/ui/widgets/kanban_board_skeleton.dart';
import 'package:client/features/kanban/ui/widgets/kanban_desktop_board.dart';
import 'package:client/features/kanban/ui/widgets/kanban_empty_state.dart';
import 'package:client/features/kanban/ui/widgets/kanban_mobile_board.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanBoardBody extends StatelessWidget {
  final KanbanState state;
  final int projectId;
  final bool isArchived;
  final String? wsAccent;
  final PageController pageController;
  final int currentColumnIndex;
  final ValueChanged<int> onColumnChanged;
  final VoidCallback onRetry;
  final VoidCallback onClearFilters;
  final ValueChanged<TaskStatus> onAddTask;
  final ValueChanged<TaskDto> onTaskTap;
  final ValueChanged<TaskDto> onTaskMove;
  final ValueChanged<TaskDto> onTaskDelete;

  const KanbanBoardBody({
    super.key,
    required this.state,
    required this.projectId,
    required this.isArchived,
    this.wsAccent,
    required this.pageController,
    required this.currentColumnIndex,
    required this.onColumnChanged,
    required this.onRetry,
    required this.onClearFilters,
    required this.onAddTask,
    required this.onTaskTap,
    required this.onTaskMove,
    required this.onTaskDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return state.when(
      initial: () => const KanbanBoardSkeleton(),
      loading: () => const KanbanBoardSkeleton(),
      error: (message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n?.retry ?? 'Retry'),
              ),
            ],
          ),
        ),
      ),
      empty: (projId, arch) => KanbanEmptyState(
        isArchived: arch,
        onCreateTask: () => onAddTask(TaskStatus.backlog),
      ),
      loaded: (projId, tasks, allTasks, arch, search, priority, assignee, err) {
        if (tasks.isEmpty &&
            (search != null || priority != null || assignee != null)) {
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
            );
          },
        );
      },
    );
  }
}
