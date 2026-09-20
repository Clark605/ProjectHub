import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/task_filter.dart';

mixin KanbanFilterMixin {
  String? _searchFilter;
  String? _priorityFilter;
  String? _assigneeFilter;
  int? _tagFilter;

  String? get searchFilter => _searchFilter;
  String? get priorityFilter => _priorityFilter;
  String? get assigneeFilter => _assigneeFilter;
  int? get tagFilter => _tagFilter;

  TaskFilter get currentFilter => TaskFilter(
    search: _searchFilter,
    priority: _priorityFilter,
    assigneeId: _assigneeFilter,
    tagId: _tagFilter,
  );

  List<TaskDto> applyFilters(List<TaskDto> tasks) => currentFilter.apply(tasks);

  void onFiltersUpdated();

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
    if (clearSearch) {
      _searchFilter = null;
    } else if (search != null) {
      _searchFilter = search.trim().isEmpty ? null : search.trim();
    }

    if (clearPriority) {
      _priorityFilter = null;
    } else if (priority != null) {
      _priorityFilter = priority.toLowerCase() == 'all' ? null : priority;
    }

    if (clearAssignee) {
      _assigneeFilter = null;
    } else if (assigneeId != null) {
      _assigneeFilter = assigneeId.toLowerCase() == 'all' ? null : assigneeId;
    }

    if (clearTag) {
      _tagFilter = null;
    } else if (tagId != null) {
      _tagFilter = tagId;
    }
    onFiltersUpdated();
  }

  void clearFilters() {
    _searchFilter = null;
    _priorityFilter = null;
    _assigneeFilter = null;
    _tagFilter = null;
    onFiltersUpdated();
  }
}
