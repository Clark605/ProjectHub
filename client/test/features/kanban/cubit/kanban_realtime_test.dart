import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/network/signalr_events.dart';
import 'package:client/features/comments/data/models/comment_dto.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';

import '../../../helpers/mock_repositories.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const CreateTaskRequest(title: 'Fallback'));
  });

  group('KanbanRealtime', () {
    late MockTaskRepository taskRepo;
    late MockProjectRepository projectRepo;
    late MockSignalRService signalR;
    late KanbanCubit cubit;

    late StreamController<TaskCreatedEvent> taskCreatedCtrl;
    late StreamController<TaskUpdatedEvent> taskUpdatedCtrl;
    late StreamController<TaskStatusChangedEvent> taskStatusChangedCtrl;
    late StreamController<TaskAssignedEvent> taskAssignedCtrl;
    late StreamController<TaskDeletedEvent> taskDeletedCtrl;
    late StreamController<CommentAddedEvent> commentAddedCtrl;
    late StreamController<CommentDeletedEvent> commentDeletedCtrl;
    late StreamController<PresenceChangedEvent> presenceChangedCtrl;
    late StreamController<String> reconnectedCtrl;

    const sampleTask = TaskDto(
      id: 101,
      projectId: 1,
      title: 'Initial Task',
      status: 'Backlog',
      priority: 'Medium',
      commentCount: 0,
    );

    const testProject = ProjectDto(
      id: 1,
      workspaceId: 10,
      name: 'Apollo Project',
      status: 'Active',
    );

    setUp(() {
      taskRepo = MockTaskRepository();
      projectRepo = MockProjectRepository();
      signalR = MockSignalRService();

      taskCreatedCtrl = StreamController<TaskCreatedEvent>.broadcast();
      taskUpdatedCtrl = StreamController<TaskUpdatedEvent>.broadcast();
      taskStatusChangedCtrl =
          StreamController<TaskStatusChangedEvent>.broadcast();
      taskAssignedCtrl = StreamController<TaskAssignedEvent>.broadcast();
      taskDeletedCtrl = StreamController<TaskDeletedEvent>.broadcast();
      commentAddedCtrl = StreamController<CommentAddedEvent>.broadcast();
      commentDeletedCtrl = StreamController<CommentDeletedEvent>.broadcast();
      presenceChangedCtrl = StreamController<PresenceChangedEvent>.broadcast();
      reconnectedCtrl = StreamController<String>.broadcast();

      when(() => signalR.taskCreated).thenAnswer((_) => taskCreatedCtrl.stream);
      when(() => signalR.taskUpdated).thenAnswer((_) => taskUpdatedCtrl.stream);
      when(
        () => signalR.taskStatusChanged,
      ).thenAnswer((_) => taskStatusChangedCtrl.stream);
      when(
        () => signalR.taskAssigned,
      ).thenAnswer((_) => taskAssignedCtrl.stream);
      when(() => signalR.taskDeleted).thenAnswer((_) => taskDeletedCtrl.stream);
      when(
        () => signalR.commentAdded,
      ).thenAnswer((_) => commentAddedCtrl.stream);
      when(
        () => signalR.commentDeleted,
      ).thenAnswer((_) => commentDeletedCtrl.stream);
      when(
        () => signalR.presenceChanged,
      ).thenAnswer((_) => presenceChangedCtrl.stream);
      when(() => signalR.reconnected).thenAnswer((_) => reconnectedCtrl.stream);
      when(() => signalR.joinWorkspace(any())).thenAnswer((_) async {});
      when(() => signalR.leaveWorkspace(any())).thenAnswer((_) async {});

      when(
        () =>
            projectRepo.getProject(1, forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => testProject);
      when(
        () => taskRepo.getTasksByProject(
          1,
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((_) async => [sampleTask]);

      cubit = KanbanCubit(taskRepo, projectRepo, signalR);
    });

    tearDown(() async {
      await cubit.close();
      await taskCreatedCtrl.close();
      await taskUpdatedCtrl.close();
      await taskStatusChangedCtrl.close();
      await taskAssignedCtrl.close();
      await taskDeletedCtrl.close();
      await commentAddedCtrl.close();
      await commentDeletedCtrl.close();
      await presenceChangedCtrl.close();
      await reconnectedCtrl.close();
    });

    test('loadTasks joins workspace and subscribes to SignalR', () async {
      await cubit.loadTasks(1);
      verify(() => signalR.joinWorkspace(10)).called(1);
      expect(cubit.state, isA<KanbanLoaded>());
    });

    test('realtime taskCreated adds task to loaded list', () async {
      await cubit.loadTasks(1);
      const newTask = TaskDto(
        id: 102,
        projectId: 1,
        title: 'New Realtime Task',
      );
      taskCreatedCtrl.add(newTask);
      await pumpEventQueue();

      final loaded = cubit.state as KanbanLoaded;
      expect(loaded.allTasks.length, 2);
      expect(loaded.allTasks.any((t) => t.id == 102), isTrue);
    });

    test('realtime taskStatusChanged updates task status', () async {
      await cubit.loadTasks(1);
      final updated = sampleTask.copyWith(status: 'InProgress');
      taskStatusChangedCtrl.add(updated);
      await pumpEventQueue();

      final loaded = cubit.state as KanbanLoaded;
      expect(loaded.allTasks.first.status, 'InProgress');
    });

    test('realtime taskAssigned updates assignee', () async {
      await cubit.loadTasks(1);
      final updated = sampleTask.copyWith(
        assigneeId: 'u99',
        assigneeName: 'Alice',
      );
      taskAssignedCtrl.add(updated);
      await pumpEventQueue();

      final loaded = cubit.state as KanbanLoaded;
      expect(loaded.allTasks.first.assigneeName, 'Alice');
    });

    test(
      'realtime commentAdded and commentDeleted modify commentCount',
      () async {
        await cubit.loadTasks(1);
        commentAddedCtrl.add(
          CommentDto(
            id: 1,
            taskId: 101,
            authorId: 'u1',
            authorName: 'User',
            content: 'Hi',
            createdAt: DateTime.now(),
          ),
        );
        await pumpEventQueue();

        var loaded = cubit.state as KanbanLoaded;
        expect(loaded.allTasks.first.commentCount, 1);

        commentDeletedCtrl.add(
          const CommentDeletedEvent(taskId: 101, commentId: 1),
        );
        await pumpEventQueue();

        loaded = cubit.state as KanbanLoaded;
        expect(loaded.allTasks.first.commentCount, 0);
      },
    );

    test(
      'realtime taskDeleted removes task and triggers empty state when last task removed',
      () async {
        await cubit.loadTasks(1);
        taskDeletedCtrl.add(const TaskDeletedEvent(taskId: 101, projectId: 1));
        await pumpEventQueue();

        final isEmpty = cubit.state.maybeWhen(
          empty: (_, _, _) => true,
          orElse: () => false,
        );
        expect(isEmpty, isTrue);
      },
    );

    test(
      'SignalR reconnected event triggers silent refresh without emitting KanbanLoading',
      () async {
        await cubit.loadTasks(1);
        final states = <KanbanState>[];
        final sub = cubit.stream.listen(states.add);

        reconnectedCtrl.add('conn-1');
        await pumpEventQueue();

        // Should not emit KanbanLoading during silent refresh
        expect(states.any((s) => s is KanbanLoading), isFalse);
        expect(cubit.state is KanbanLoaded, isTrue);

        await sub.cancel();
      },
    );

    test(
      'createTask reconciles idempotently and does not duplicate task when SignalR taskCreated arrives first',
      () async {
        await cubit.loadTasks(1);

        when(() => taskRepo.createTask(1, any())).thenAnswer((
          invocation,
        ) async {
          const created = TaskDto(
            id: 200,
            projectId: 1,
            title: 'Created Task',
            status: 'Backlog',
          );
          taskCreatedCtrl.add(created);
          await pumpEventQueue();
          return created;
        });

        await cubit.createTask(
          1,
          const CreateTaskRequest(title: 'Created Task'),
        );

        final loaded = cubit.state as KanbanLoaded;
        final occurrences = loaded.allTasks.where((t) => t.id == 200).length;
        expect(occurrences, 1);
      },
    );

    test(
      'createTask with initialStatus updates status cleanly and does not duplicate when SignalR emits Backlog first',
      () async {
        await cubit.loadTasks(1);

        when(() => taskRepo.createTask(1, any())).thenAnswer((
          invocation,
        ) async {
          const created = TaskDto(
            id: 200,
            projectId: 1,
            title: 'In Progress Task',
            status: 'Backlog',
          );
          taskCreatedCtrl.add(created);
          await pumpEventQueue();
          return created;
        });
        when(() => taskRepo.updateTaskStatus(200, 'InProgress')).thenAnswer(
          (_) async => const TaskDto(
            id: 200,
            projectId: 1,
            title: 'In Progress Task',
            status: 'InProgress',
          ),
        );

        final created = await cubit.createTask(
          1,
          const CreateTaskRequest(title: 'In Progress Task'),
          initialStatus: 'InProgress',
        );

        expect(created.status, 'InProgress');
        final loaded = cubit.state as KanbanLoaded;
        final occurrences = loaded.allTasks.where((t) => t.id == 200).length;
        expect(occurrences, 1);
        expect(
          loaded.allTasks.firstWhere((t) => t.id == 200).status,
          'InProgress',
        );
      },
    );
  });
}
