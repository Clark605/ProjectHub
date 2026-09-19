import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/tasks/cubit/my_tasks_state.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/ui/widgets/my_tasks_empty_view.dart';
import 'package:client/features/tasks/ui/widgets/my_tasks_section.dart';
import 'package:client/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    return state.when(
      initial: () => [
        const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
      ],
      loading: () => [
        const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
      ],
      error: (message) => [
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(message, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
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
        ),
      ],
      empty: (_) => [const SliverFillRemaining(child: MyTasksEmptyView())],
      loaded: (wsId, urgent, inProgress, todo, done, showDone, _) {
        final hasTasks =
            urgent.isNotEmpty || inProgress.isNotEmpty || todo.isNotEmpty || done.isNotEmpty;
        if (!hasTasks) {
          return [const SliverFillRemaining(child: MyTasksEmptyView())];
        }

        return [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (urgent.isNotEmpty)
                  MyTasksSection(
                    emoji: '🚨',
                    title: l10n?.overdueUrgent ?? 'Overdue & Urgent',
                    tasks: urgent,
                    activeWorkspaceAccent: wsAccent,
                    onTaskTap: onTaskTap,
                    onTaskStatusTap: onTaskMove,
                  ),
                if (inProgress.isNotEmpty)
                  MyTasksSection(
                    emoji: '⚡',
                    title: l10n?.inProgress ?? 'In Progress',
                    tasks: inProgress,
                    activeWorkspaceAccent: wsAccent,
                    onTaskTap: onTaskTap,
                    onTaskStatusTap: onTaskMove,
                  ),
                if (todo.isNotEmpty)
                  MyTasksSection(
                    emoji: '📋',
                    title: l10n?.upNext ?? 'Up Next',
                    tasks: todo,
                    activeWorkspaceAccent: wsAccent,
                    onTaskTap: onTaskTap,
                    onTaskStatusTap: onTaskMove,
                  ),
                MyTasksSection(
                  emoji: '✅',
                  title: l10n?.recentlyDone ?? 'Recently Done',
                  tasks: done,
                  isCollapsible: true,
                  isCollapsed: !showDone,
                  activeWorkspaceAccent: wsAccent,
                  onToggleCollapse: onToggleCollapse,
                  onTaskTap: onTaskTap,
                  onTaskStatusTap: onTaskMove,
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ];
      },
    );
  }
}
