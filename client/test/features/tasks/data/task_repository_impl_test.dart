import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_remote_data_source.dart';
import 'package:client/features/tasks/data/task_repository_impl.dart';

class _FakeTaskRemoteDataSource implements TaskRemoteDataSource {
  final List<TaskDto> tasks = [];
  int getTasksCallCount = 0;
  int getMyTasksCallCount = 0;

  @override
  Future<List<TaskDto>> getTasksByProject(
    int projectId, {
    String? status,
    String? assigneeId,
    String? priority,
  }) async {
    getTasksCallCount++;
    return tasks.where((t) => t.projectId == projectId).toList();
  }

  @override
  Future<List<TaskDto>> getMyTasks(int workspaceId) async {
    getMyTasksCallCount++;
    return tasks.toList();
  }

  @override
  Future<TaskDto> getTask(int taskId) async {
    return tasks.firstWhere((t) => t.id == taskId);
  }

  @override
  Future<TaskDto> createTask(int projectId, CreateTaskRequest request) async {
    final t = TaskDto(
      id: tasks.length + 1,
      projectId: projectId,
      title: request.title,
      description: request.description,
      priority: request.priority,
      status: request.status ?? 'Backlog',
    );
    tasks.add(t);
    return t;
  }

  @override
  Future<TaskDto> updateTask(int taskId, UpdateTaskRequest request) async {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    final updated = tasks[idx].copyWith(title: request.title);
    tasks[idx] = updated;
    return updated;
  }

  @override
  Future<TaskDto> updateTaskStatus(int taskId, String status) async {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    final updated = tasks[idx].copyWith(status: status);
    tasks[idx] = updated;
    return updated;
  }

  @override
  Future<TaskDto> updateTaskAssignee(int taskId, String? assigneeId) async {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    final updated = tasks[idx].copyWith(assigneeId: assigneeId);
    tasks[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteTask(int taskId) async {
    tasks.removeWhere((t) => t.id == taskId);
  }
}

void main() {
  group('TaskRepositoryImpl cache isolation & unmodifiability', () {
    late _FakeTaskRemoteDataSource remoteDataSource;
    late TaskRepositoryImpl repo;

    const sampleTask1 = TaskDto(
      id: 1,
      projectId: 10,
      title: 'Task 1',
      status: 'Backlog',
    );
    const sampleTask2 = TaskDto(
      id: 2,
      projectId: 10,
      title: 'Task 2',
      status: 'Todo',
    );

    setUp(() {
      remoteDataSource = _FakeTaskRemoteDataSource();
      remoteDataSource.tasks.addAll([sampleTask1, sampleTask2]);
      repo = TaskRepositoryImpl(remoteDataSource);
    });

    test('getTasksByProject returns unmodifiable list', () async {
      final tasks = await repo.getTasksByProject(10);
      expect(tasks.length, 2);
      expect(() => (tasks as dynamic).add(sampleTask1), throwsUnsupportedError);
    });

    test('cached hit returns unmodifiable list without invoking remote', () async {
      await repo.getTasksByProject(10);
      expect(remoteDataSource.getTasksCallCount, 1);

      final cachedTasks = await repo.getTasksByProject(10);
      expect(remoteDataSource.getTasksCallCount, 1);
      expect(() => (cachedTasks as dynamic).removeAt(0), throwsUnsupportedError);
    });

    test('deleteTask does not mutate previously returned list in place', () async {
      final initialTasks = await repo.getTasksByProject(10);
      expect(initialTasks.length, 2);

      await repo.deleteTask(1);

      // initialTasks held by caller must NOT have been mutated in place
      expect(initialTasks.length, 2);

      // fresh read reflects deletion
      final afterDelete = await repo.getTasksByProject(10);
      expect(afterDelete.length, 1);
      expect(afterDelete.first.id, 2);
    });

    test('getTask adds to cache without mutating original cached list reference in place', () async {
      final initialTasks = await repo.getTasksByProject(10);
      expect(initialTasks.length, 2);

      final task3 = TaskDto(id: 3, projectId: 10, title: 'Task 3', status: 'Done');
      remoteDataSource.tasks.add(task3);

      await repo.getTask(3);

      // initialTasks held by caller remains untouched
      expect(initialTasks.length, 2);

      final updatedTasks = await repo.getTasksByProject(10);
      expect(updatedTasks.length, 3);
    });

    test('getMyTasks returns unmodifiable list and caches correctly', () async {
      final myTasks = await repo.getMyTasks(100);
      expect(myTasks.length, 2);
      expect(() => (myTasks as dynamic).clear(), throwsUnsupportedError);
      expect(remoteDataSource.getMyTasksCallCount, 1);

      await repo.getMyTasks(100);
      expect(remoteDataSource.getMyTasksCallCount, 1);
    });
  });
}
