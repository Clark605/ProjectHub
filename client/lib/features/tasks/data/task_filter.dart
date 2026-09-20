import 'package:client/features/tasks/data/models/task_dto.dart';

/// Pure filtering utility for tasks by search query, priority, and assignee.
class TaskFilter {
  final String? search;
  final String? priority;
  final String? assigneeId;

  const TaskFilter({this.search, this.priority, this.assigneeId});

  List<TaskDto> apply(List<TaskDto> tasks) {
    return tasks.where((task) {
      if (search != null && search!.isNotEmpty) {
        final query = search!.toLowerCase();
        final matchesTitle = task.title.toLowerCase().contains(query);
        final matchesDesc = task.description.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc) return false;
      }
      if (priority != null && priority!.isNotEmpty) {
        if (task.priority.toLowerCase() != priority!.toLowerCase()) {
          return false;
        }
      }
      if (assigneeId != null && assigneeId!.isNotEmpty) {
        if (assigneeId == 'unassigned') {
          if (task.assigneeId != null && task.assigneeId!.isNotEmpty) {
            return false;
          }
        } else if (task.assigneeId != assigneeId) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
