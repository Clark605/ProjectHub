import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/task_remote_data_source.dart';
import 'package:client/features/tasks/data/task_repository_impl.dart';

class MockTaskRemoteDataSource extends Mock implements TaskRemoteDataSource {}

void main() {
  group('TaskRepositoryImpl cache isolation & unmodifiability', () {
    late MockTaskRemoteDataSource remoteDataSource;
    late TaskRepositoryImpl repo;
    late List<TaskDto> remoteTasks;

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
      remoteDataSource = MockTaskRemoteDataSource();
      remoteTasks = [sampleTask1, sampleTask2];

      when(
        () => remoteDataSource.getTasksByProject(
          any(),
          status: any(named: 'status'),
          assigneeId: any(named: 'assigneeId'),
          priority: any(named: 'priority'),
        ),
      ).thenAnswer((inv) async {
        final pid = inv.positionalArguments[0] as int;
        return remoteTasks.where((t) => t.projectId == pid).toList();
      });

      when(
        () => remoteDataSource.getMyTasks(any()),
      ).thenAnswer((_) async => remoteTasks.toList());

      when(() => remoteDataSource.getTask(any())).thenAnswer((inv) async {
        final id = inv.positionalArguments[0] as int;
        return remoteTasks.firstWhere((t) => t.id == id);
      });

      when(() => remoteDataSource.deleteTask(any())).thenAnswer((inv) async {
        final id = inv.positionalArguments[0] as int;
        remoteTasks.removeWhere((t) => t.id == id);
      });

      repo = TaskRepositoryImpl(remoteDataSource);
    });

    test('getTasksByProject returns unmodifiable list', () async {
      final tasks = await repo.getTasksByProject(10);
      expect(tasks.length, 2);
      expect(
        () => (tasks as dynamic).add(sampleTask1),
        throwsUnsupportedError,
      );
    });

    test(
      'cached hit returns unmodifiable list without invoking remote',
      () async {
        await repo.getTasksByProject(10);
        verify(() => remoteDataSource.getTasksByProject(10)).called(1);

        final cachedTasks = await repo.getTasksByProject(10);
        verifyNoMoreInteractions(remoteDataSource);
        expect(
          () => (cachedTasks as dynamic).removeAt(0),
          throwsUnsupportedError,
        );
      },
    );

    test(
      'deleteTask does not mutate previously returned list in place',
      () async {
        final initialTasks = await repo.getTasksByProject(10);
        expect(initialTasks.length, 2);

        await repo.deleteTask(1);

        // initialTasks held by caller must NOT have been mutated in place
        expect(initialTasks.length, 2);

        // fresh read reflects deletion
        final afterDelete = await repo.getTasksByProject(10);
        expect(afterDelete.length, 1);
        expect(afterDelete.first.id, 2);
      },
    );

    test(
      'getTask adds to cache without mutating original cached list reference in place',
      () async {
        final initialTasks = await repo.getTasksByProject(10);
        expect(initialTasks.length, 2);

        const task3 = TaskDto(
          id: 3,
          projectId: 10,
          title: 'Task 3',
          status: 'Done',
        );
        remoteTasks.add(task3);

        await repo.getTask(3);

        // initialTasks held by caller remains untouched
        expect(initialTasks.length, 2);

        final updatedTasks = await repo.getTasksByProject(10);
        expect(updatedTasks.length, 3);
      },
    );

    test('getMyTasks returns unmodifiable list and caches correctly', () async {
      final myTasks = await repo.getMyTasks(100);
      expect(myTasks.length, 2);
      expect(() => (myTasks as dynamic).clear(), throwsUnsupportedError);
      verify(() => remoteDataSource.getMyTasks(100)).called(1);

      await repo.getMyTasks(100);
      verifyNoMoreInteractions(remoteDataSource);
    });
  });
}
