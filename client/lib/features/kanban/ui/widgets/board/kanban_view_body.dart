import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/kanban/ui/widgets/board/kanban_archived_banner.dart';
import 'package:client/features/kanban/ui/widgets/board/kanban_board_body.dart';
import 'package:client/features/kanban/ui/widgets/filters/kanban_filter_bar.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/tasks/data/task_filter.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';

class KanbanViewBody extends StatelessWidget {
  final KanbanState state;
  final int projectId;
  final bool isArchived;
  final String? wsAccent;
  final PageController? pageController;
  final int? currentColumnIndex;
  final List<MemberDto> members;
  final KanbanCubit? cubit;
  final ValueChanged<int>? onColumnChanged;
  final ValueChanged<TaskStatus>? onAddTask;

  const KanbanViewBody({
    super.key,
    required this.state,
    required this.projectId,
    required this.isArchived,
    required this.wsAccent,
    this.pageController,
    this.currentColumnIndex,
    required this.members,
    this.cubit,
    this.onColumnChanged,
    this.onAddTask,
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
    final effectiveCubit = cubit ?? context.read<KanbanCubit>();
    final activeFilter = state is KanbanLoaded
        ? (state as KanbanLoaded).filter
        : const TaskFilter();

    return AmbientGlowBackground(
      child: SafeArea(
        child: Column(
          children: [
            if (isArchived) const KanbanArchivedBanner(),
            KanbanFilterBar(
              selectedPriority: activeFilter.priority,
              selectedAssignee: activeFilter.assigneeId,
              selectedTagId: activeFilter.tagId,
              availableTags: _extractTags(),
              searchQuery: activeFilter.search,
              members: members,
              onPrioritySelected: (p) => effectiveCubit.setFilter(priority: p),
              onAssigneeSelected: (a) =>
                  effectiveCubit.setFilter(assigneeId: a),
              onTagSelected: (t) =>
                  effectiveCubit.setFilter(tagId: t, clearTag: t == null),
              onSearchChanged: (q) => effectiveCubit.setFilter(search: q),
              onClearFilters: effectiveCubit.clearFilters,
            ),
            Expanded(
              child: RefreshIndicator(
                notificationPredicate: (n) => n.metrics.axis == Axis.vertical,
                onRefresh: () =>
                    effectiveCubit.refreshTasks(forceRefresh: true),
                child: KanbanBoardBody(
                  state: state,
                  projectId: projectId,
                  isArchived: isArchived,
                  wsAccent: wsAccent,
                  pageController: pageController,
                  currentColumnIndex: currentColumnIndex,
                  onColumnChanged: onColumnChanged,
                  onRetry: () =>
                      effectiveCubit.loadTasks(projectId, forceRefresh: true),
                  onClearFilters: effectiveCubit.clearFilters,
                  onAddTask: onAddTask,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
