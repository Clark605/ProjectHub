import 'package:client/core/errors/app_failure.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/tasks/data/task_filter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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
    AppFailure? failure,
  }) = KanbanLoaded;
  const factory KanbanState.empty({
    required int projectId,
    @Default(false) bool isArchived,
    AppFailure? failure,
  }) = KanbanEmpty;
  const factory KanbanState.error(AppFailure failure) = KanbanError;

  bool get isArchived => maybeWhen(
    loaded: (_, _, _, isArchived, _, _) => isArchived,
    empty: (_, isArchived, _) => isArchived,
    orElse: () => false,
  );

  AppFailure? get failure => maybeWhen(
    loaded: (_, _, _, _, _, failure) => failure,
    empty: (_, _, failure) => failure,
    error: (failure) => failure,
    orElse: () => null,
  );

  Map<TaskStatus, List<TaskDto>> get tasksByStatus {
    final map = <TaskStatus, List<TaskDto>>{
      for (final status in TaskStatus.values) status: <TaskDto>[],
    };

    maybeWhen(
      loaded: (projectId, tasks, allTasks, isArchived, filter, failure) {
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
