import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/theme/breakpoints.dart';
import 'package:client/core/widgets/app_error_state.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/kanban/ui/widgets/board/kanban_board_skeleton.dart';
import 'package:client/features/kanban/ui/widgets/board/kanban_desktop_board.dart';
import 'package:client/features/kanban/ui/widgets/board/kanban_empty_state.dart';
import 'package:client/features/kanban/ui/widgets/board/kanban_mobile_board.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:flutter/material.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return state.when(
      initial: () => const KanbanBoardSkeleton(),
      loading: () => const KanbanBoardSkeleton(),
      error: (failure) => AppErrorState(
        errorMessage: failure.toLocalizedMessage(l10n),
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
              padding: AppSpacing.edgeInsetsAllXxl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.filter_list_off_rounded,
                    size: AppIconSize.display,
                    color: AppColors.textSecondary,
                  ),
                  AppSpacing.gapHMd,
                  Text(
                    l10n.noTasksMatchFilters,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.gapHMd,
                  OutlinedButton(
                    onPressed: onClearFilters,
                    child: Text(l10n.clearFilters),
                  ),
                ],
              ),
            ),
          );
        }

        final tasksByStatus = state.tasksByStatus;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < Breakpoints.mobile;
            if (isMobile) {
              return KanbanMobileBoard(
                pageController: pageController,
                currentColumnIndex: currentColumnIndex,
                onColumnChanged: onColumnChanged,
                tasksByStatus: tasksByStatus,
                isArchived: arch,
                wsAccent: wsAccent,
                onAddTask: onAddTask,
              );
            }
            return KanbanDesktopBoard(
              tasksByStatus: tasksByStatus,
              isArchived: arch,
              availableHeight: constraints.maxHeight,
              wsAccent: wsAccent,
              onAddTask: onAddTask,
            );
          },
        );
      },
    );
  }
}
