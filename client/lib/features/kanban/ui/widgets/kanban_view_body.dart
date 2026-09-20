import 'package:flutter/material.dart';

import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/kanban/ui/widgets/kanban_archived_banner.dart';
import 'package:client/features/kanban/ui/widgets/kanban_board_body.dart';
import 'package:client/features/kanban/ui/widgets/kanban_filter_bar.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';

class KanbanViewBody extends StatelessWidget {
  final KanbanState state;
  final int projectId;
  final bool isArchived;
  final String? wsAccent;
  final PageController pageController;
  final int currentColumnIndex;
  final List<MemberDto> members;
  final KanbanCubit cubit;
  final ValueChanged<int> onColumnChanged;
  final ValueChanged<TaskStatus> onAddTask;
  final ValueChanged<TaskDto> onTaskTap;
  final ValueChanged<TaskDto> onTaskMove;
  final ValueChanged<TaskDto> onTaskDelete;

  const KanbanViewBody({
    super.key,
    required this.state,
    required this.projectId,
    required this.isArchived,
    required this.wsAccent,
    required this.pageController,
    required this.currentColumnIndex,
    required this.members,
    required this.cubit,
    required this.onColumnChanged,
    required this.onAddTask,
    required this.onTaskTap,
    required this.onTaskMove,
    required this.onTaskDelete,
  });

  List<TagDto> _extractTags() {
    return state.maybeMap(
      loaded: (l) {
        final map = <int, TagDto>{};
        for (final task in l.allTasks) {
          for (final tag in task.tags) {
            map[tag.id] = tag;
          }
        }
        return map.values.toList()..sort((a, b) => a.name.compareTo(b.name));
      },
      orElse: () => const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AmbientGlowBackground(
      child: SafeArea(
        child: Column(
          children: [
            if (isArchived) const KanbanArchivedBanner(),
            KanbanFilterBar(
              selectedPriority: cubit.priorityFilter,
              selectedAssignee: cubit.assigneeFilter,
              selectedTagId: cubit.tagFilter,
              availableTags: _extractTags(),
              searchQuery: cubit.searchFilter,
              members: members,
              onPrioritySelected: (p) => cubit.setFilter(priority: p),
              onAssigneeSelected: (a) => cubit.setFilter(assigneeId: a),
              onTagSelected: (t) =>
                  cubit.setFilter(tagId: t, clearTag: t == null),
              onSearchChanged: (q) => cubit.setFilter(search: q),
              onClearFilters: cubit.clearFilters,
            ),
            Expanded(
              child: RefreshIndicator(
                notificationPredicate: (n) => n.metrics.axis == Axis.vertical,
                onRefresh: () => cubit.loadTasks(projectId, forceRefresh: true),
                child: KanbanBoardBody(
                  state: state,
                  projectId: projectId,
                  isArchived: isArchived,
                  wsAccent: wsAccent,
                  pageController: pageController,
                  currentColumnIndex: currentColumnIndex,
                  onColumnChanged: onColumnChanged,
                  onRetry: () => cubit.loadTasks(projectId, forceRefresh: true),
                  onClearFilters: cubit.clearFilters,
                  onAddTask: onAddTask,
                  onTaskTap: onTaskTap,
                  onTaskMove: onTaskMove,
                  onTaskDelete: onTaskDelete,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
