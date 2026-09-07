import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_status.dart';

part 'kanban_state.freezed.dart';

@freezed
abstract class KanbanState with _$KanbanState {
  const KanbanState._();

  const factory KanbanState.initial() = _KanbanInitial;
  const factory KanbanState.loading() = _KanbanLoading;
  const factory KanbanState.loaded({
    required int projectId,
    required List<TaskDto> tasks,
    required List<TaskDto> allTasks,
    @Default(false) bool isArchived,
    String? searchFilter,
    String? priorityFilter,
    String? assigneeFilter,
    String? errorMessage,
  }) = KanbanLoaded;
  const factory KanbanState.empty({
    required int projectId,
    @Default(false) bool isArchived,
  }) = _KanbanEmpty;
  const factory KanbanState.error(String message) = _KanbanError;

  Map<TaskStatus, List<TaskDto>> get tasksByStatus {
    final map = <TaskStatus, List<TaskDto>>{
      for (final status in TaskStatus.values) status: <TaskDto>[],
    };

    maybeWhen(
      loaded:
          (
            projectId,
            tasks,
            allTasks,
            isArchived,
            searchFilter,
            priorityFilter,
            assigneeFilter,
            errorMessage,
          ) {
            for (final task in tasks) {
              map[task.statusEnum]?.add(task);
            }
          },
      orElse: () {},
    );

    return map;
  }
}
