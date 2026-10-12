import 'package:flutter/material.dart';

import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/widgets/app_error_state.dart';
import 'package:client/features/tasks/cubit/my_tasks_state.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/ui/widgets/my_tasks_empty_view.dart';
import 'package:client/features/tasks/ui/widgets/my_tasks_section.dart';

class MyTasksContentSlivers {
  static List<Widget> build({
    required BuildContext context,
    required MyTasksState state,
    required String? wsAccent,
    required ValueChanged<TaskDto> onTaskTap,
    required ValueChanged<TaskDto> onTaskMove,
    required VoidCallback onToggleCollapse,
    required VoidCallback onRetry,
  }) {
    final l10n = context.l10n;

    return state.when(
      initial: () => [
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      loading: () => [
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (failure) => [
        SliverFillRemaining(
          child: AppErrorState(
            errorMessage: failure.toLocalizedMessage(l10n),
            onRetry: onRetry,
          ),
        ),
      ],
      empty: (_) => [const SliverFillRemaining(child: MyTasksEmptyView())],
      loaded: (wsId, urgent, inProgress, todo, done, showDone, _) {
        final hasTasks =
            urgent.isNotEmpty ||
            inProgress.isNotEmpty ||
            todo.isNotEmpty ||
            done.isNotEmpty;
        if (!hasTasks) {
          return [const SliverFillRemaining(child: MyTasksEmptyView())];
        }

        return [
          SliverPadding(
            padding: AppSpacing.edgeInsetsHXl,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (urgent.isNotEmpty)
                  MyTasksSection(
                    emoji: '🚨',
                    title: l10n.overdueUrgent,
                    tasks: urgent,
                    activeWorkspaceAccent: wsAccent,
                    onTaskTap: onTaskTap,
                    onTaskStatusTap: onTaskMove,
                  ),
                if (inProgress.isNotEmpty)
                  MyTasksSection(
                    emoji: '⚡',
                    title: l10n.inProgress,
                    tasks: inProgress,
                    activeWorkspaceAccent: wsAccent,
                    onTaskTap: onTaskTap,
                    onTaskStatusTap: onTaskMove,
                  ),
                if (todo.isNotEmpty)
                  MyTasksSection(
                    emoji: '📋',
                    title: l10n.upNext,
                    tasks: todo,
                    activeWorkspaceAccent: wsAccent,
                    onTaskTap: onTaskTap,
                    onTaskStatusTap: onTaskMove,
                  ),
                MyTasksSection(
                  emoji: '✅',
                  title: l10n.recentlyDone,
                  tasks: done,
                  isCollapsible: true,
                  isCollapsed: !showDone,
                  activeWorkspaceAccent: wsAccent,
                  onToggleCollapse: onToggleCollapse,
                  onTaskTap: onTaskTap,
                  onTaskStatusTap: onTaskMove,
                ),
                AppSpacing.gapHXxxl,
              ]),
            ),
          ),
        ];
      },
    );
  }
}
