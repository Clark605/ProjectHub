import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/tasks/data/task_filter.dart';

part 'kanban_state.freezed.dart';

@freezed
abstract class KanbanState with _$KanbanState {
  const KanbanState._();

  const factory KanbanState.initial() = KanbanInitial;
  const factory KanbanState.loading() = KanbanLoading;
  const factory KanbanState.loaded({
    required int projectId,
    required List<TaskDto> tasks,
    required List<TaskDto> allTasks,
    @Default(false) bool isArchived,
    @Default(TaskFilter()) TaskFilter filter,
    String? errorMessage,
  }) = KanbanLoaded;
  const factory KanbanState.empty({
    required int projectId,
    @Default(false) bool isArchived,
    String? errorMessage,
  }) = KanbanEmpty;
  const factory KanbanState.error(String message) = KanbanError;

  bool get isArchived => maybeWhen(
    loaded: (_, _, _, isArchived, _, _) => isArchived,
    empty: (_, isArchived, _) => isArchived,
    orElse: () => false,
  );

  String? get errorMessage => maybeWhen(
    loaded: (_, _, _, _, _, errorMessage) => errorMessage,
    empty: (_, _, errorMessage) => errorMessage,
    error: (msg) => msg,
    orElse: () => null,
  );

  Map<TaskStatus, List<TaskDto>> get tasksByStatus {
    final map = <TaskStatus, List<TaskDto>>{
      for (final status in TaskStatus.values) status: <TaskDto>[],
    };

    maybeWhen(
      loaded: (projectId, tasks, allTasks, isArchived, filter, errorMessage) {
        for (final task in tasks) {
          map[task.statusEnum]?.add(task);
        }
      },
      orElse: () {},
    );

    return map;
  }
}

extension KanbanLoadedX on KanbanLoaded {
  String? get searchFilter => filter.search;
  String? get priorityFilter => filter.priority;
  String? get assigneeFilter => filter.assigneeId;
  int? get tagFilter => filter.tagId;
}
