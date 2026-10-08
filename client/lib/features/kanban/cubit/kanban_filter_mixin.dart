import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/task_filter.dart';

mixin KanbanFilterMixin on SafeActionCubit<KanbanState> {
  void emitLoaded(
    List<TaskDto> allTasks, {
    TaskFilter? filter,
    String? errorMessage,
  });

  TaskFilter get currentFilter {
    final s = state;
    if (s is KanbanLoaded) return s.filter;
    return const TaskFilter();
  }

  String? get searchFilter => currentFilter.search;
  String? get priorityFilter => currentFilter.priority;
  String? get assigneeFilter => currentFilter.assigneeId;
  int? get tagFilter => currentFilter.tagId;

  List<TaskDto> applyFilters(List<TaskDto> tasks, [TaskFilter? filter]) =>
      (filter ?? currentFilter).apply(tasks);

  void setFilter({
    String? search,
    String? priority,
    String? assigneeId,
    int? tagId,
    bool clearSearch = false,
    bool clearPriority = false,
    bool clearAssignee = false,
    bool clearTag = false,
  }) {
    final existing = currentFilter;
    final newSearch = clearSearch
        ? null
        : (search != null
              ? (search.trim().isEmpty ? null : search.trim())
              : existing.search);
    final newPriority = clearPriority
        ? null
        : (priority != null
              ? (priority.toLowerCase() == 'all' ? null : priority)
              : existing.priority);
    final newAssignee = clearAssignee
        ? null
        : (assigneeId != null
              ? (assigneeId.toLowerCase() == 'all' ? null : assigneeId)
              : existing.assigneeId);
    final newTag = clearTag ? null : (tagId ?? existing.tagId);

    final nextFilter = TaskFilter(
      search: newSearch,
      priority: newPriority,
      assigneeId: newAssignee,
      tagId: newTag,
    );

    final s = state;
    if (s is KanbanLoaded) {
      emitLoaded(s.allTasks, filter: nextFilter);
    }
  }

  void clearFilters() {
    final s = state;
    if (s is KanbanLoaded) {
      emitLoaded(s.allTasks, filter: const TaskFilter());
    }
  }
}
