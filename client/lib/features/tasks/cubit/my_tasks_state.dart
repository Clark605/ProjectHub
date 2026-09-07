import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:client/features/tasks/data/models/task_dto.dart';

part 'my_tasks_state.freezed.dart';

@freezed
abstract class MyTasksState with _$MyTasksState {
  const MyTasksState._();

  const factory MyTasksState.initial() = _MyTasksInitial;
  const factory MyTasksState.loading() = _MyTasksLoading;
  const factory MyTasksState.loaded({
    required int workspaceId,
    required List<TaskDto> urgentTasks,
    required List<TaskDto> inProgressTasks,
    required List<TaskDto> todoTasks,
    required List<TaskDto> doneTasks,
    @Default(false) bool showDone,
    String? errorMessage,
  }) = MyTasksLoaded;
  const factory MyTasksState.empty({required int workspaceId}) = _MyTasksEmpty;
  const factory MyTasksState.error(String message) = _MyTasksError;

  int get totalActiveCount => maybeWhen(
    loaded: (_, urgent, inProg, todo, _, _, _) =>
        urgent.length + inProg.length + todo.length,
    orElse: () => 0,
  );
}
