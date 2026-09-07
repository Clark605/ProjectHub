import 'package:flutter_test/flutter_test.dart';
import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/tasks/cubit/my_tasks_cubit.dart';
import 'package:client/features/tasks/cubit/my_tasks_state.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_repository.dart';

class _FakeTaskRepository implements TaskRepository {
  List<TaskDto> tasks = [];
  bool shouldThrow = false;
  String errorMessage = 'Failed to fetch tasks';

  @override
  void clearCache([int? projectId]) {}

  @override
  Future<List<TaskDto>> getTasksByProject(
    int projectId, {
    String? status,
    String? assigneeId,
    String? priority,
    bool forceRefresh = false,
  }) async {
    if (shouldThrow) throw AppException(message: errorMessage);
    return tasks;
  }

  @override
  Future<List<TaskDto>> getMyTasks(
    int workspaceId, {
    bool forceRefresh = false,
  }) async {
    if (shouldThrow) throw AppException(message: errorMessage);
    return tasks;
  }

  @override
  Future<TaskDto> getTask(int taskId, {bool forceRefresh = false}) async {
    return tasks.firstWhere((t) => t.id == taskId);
  }

  @override
  Future<TaskDto> createTask(int projectId, CreateTaskRequest request) async {
    final task = TaskDto(
      id: tasks.length + 1,
      projectId: projectId,
      title: request.title,
      description: request.description,
      priority: request.priority,
      status: 'Backlog',
      assigneeId: request.assigneeId,
      dueDate: request.dueDate,
    );
    tasks.add(task);
    return task;
  }

  @override
  Future<TaskDto> updateTask(int taskId, UpdateTaskRequest request) async {
    final index = tasks.indexWhere((t) => t.id == taskId);
    final updated = tasks[index].copyWith(
      title: request.title,
      description: request.description,
      priority: request.priority,
      assigneeId: request.assigneeId,
      dueDate: request.dueDate,
    );
    tasks[index] = updated;
    return updated;
  }

  @override
  Future<TaskDto> updateTaskStatus(int taskId, String status) async {
    final index = tasks.indexWhere((t) => t.id == taskId);
    final updated = tasks[index].copyWith(status: status);
    tasks[index] = updated;
    return updated;
  }

  @override
  Future<TaskDto> updateTaskAssignee(int taskId, String? assigneeId) async {
    final index = tasks.indexWhere((t) => t.id == taskId);
    final updated = tasks[index].copyWith(assigneeId: assigneeId);
    tasks[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteTask(int taskId) async {
    tasks.removeWhere((t) => t.id == taskId);
  }

  @override
  bool hasCachedTasks(int projectId) => false;
}

void main() {
  late _FakeTaskRepository repo;
  late MyTasksCubit cubit;

  setUp(() {
    repo = _FakeTaskRepository();
    cubit = MyTasksCubit(repo);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is MyTasksState.initial()', () {
    expect(cubit.state, const MyTasksState.initial());
  });

  test('loadMyTasks emits loading then empty when no tasks exist', () async {
    repo.tasks = [];

    final expected = [
      const MyTasksState.loading(),
      const MyTasksState.empty(workspaceId: 10),
    ];

    expectLater(cubit.stream, emitsInOrder(expected));
    await cubit.loadMyTasks(10);
  });

  test(
    'loadMyTasks groups tasks into urgent, inProgress, todo, and done sections',
    () async {
      repo.tasks = [
        // Urgent priority
        const TaskDto(
          id: 1,
          projectId: 1,
          title: 'Urgent Task',
          priority: 'Urgent',
          status: 'Todo',
        ),
        // Overdue task
        TaskDto(
          id: 2,
          projectId: 1,
          title: 'Overdue Task',
          priority: 'Medium',
          status: 'Todo',
          dueDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
        // In Progress task
        const TaskDto(
          id: 3,
          projectId: 1,
          title: 'In Progress Task',
          priority: 'Medium',
          status: 'InProgress',
        ),
        // Up Next task (Todo)
        const TaskDto(
          id: 4,
          projectId: 1,
          title: 'Todo Task',
          priority: 'Low',
          status: 'Todo',
        ),
        // Done task
        TaskDto(
          id: 5,
          projectId: 1,
          title: 'Done Task',
          priority: 'Medium',
          status: 'Done',
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        // Due today (midnight date-only) - should NOT be urgent
        TaskDto(
          id: 6,
          projectId: 1,
          title: 'Due Today Task',
          priority: 'Low',
          status: 'Todo',
          dueDate: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ),
        ),
      ];

      await cubit.loadMyTasks(10);

      cubit.state.maybeWhen(
        loaded: (wsId, urgent, inProgress, todo, done, showDone, _) {
          expect(wsId, 10);
          expect(urgent.length, 2);
          expect(urgent.map((t) => t.id), containsAll([1, 2]));
          expect(inProgress.length, 1);
          expect(inProgress.first.id, 3);
          expect(todo.length, 2);
          expect(todo.map((t) => t.id), containsAll([4, 6]));
          expect(done.length, 1);
          expect(done.first.id, 5);
          expect(showDone, false);
        },
        orElse: () => fail('State should be MyTasksLoaded'),
      );
    },
  );

  test(
    'toggleDoneVisibility toggles showDone boolean in loaded state',
    () async {
      repo.tasks = [
        const TaskDto(id: 1, projectId: 1, title: 'Test Task', status: 'Todo'),
      ];

      await cubit.loadMyTasks(10);

      expect(cubit.showDone, false);
      cubit.toggleDoneVisibility();
      expect(cubit.showDone, true);

      cubit.state.maybeWhen(
        loaded: (_, _, _, _, _, showDone, _) => expect(showDone, true),
        orElse: () => fail('State should be MyTasksLoaded'),
      );
    },
  );

  test('loadMyTasks handles repository error via SafeActionCubit', () async {
    repo.shouldThrow = true;
    repo.errorMessage = 'Network timeout';

    final expected = [
      const MyTasksState.loading(),
      isA<MyTasksState>().having(
        (s) => s.maybeWhen(error: (msg) => msg, orElse: () => ''),
        'errorMessage',
        contains('Network timeout'),
      ),
    ];

    expectLater(cubit.stream, emitsInOrder(expected));
    await cubit.loadMyTasks(10);
  });
}
