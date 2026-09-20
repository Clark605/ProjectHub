import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/network/signalr_events.dart';
import 'package:client/core/network/signalr_service.dart';
import 'package:client/core/storage/secure_storage_service.dart';
import 'package:client/features/comments/data/models/comment_dto.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import '../ui/fakes/kanban_test_fakes.dart';

class _FakeSignalRService extends SignalRService {
  _FakeSignalRService() : super(SecureStorageService());

  final _taskCreatedCtrl = StreamController<TaskCreatedEvent>.broadcast();
  final _taskUpdatedCtrl = StreamController<TaskUpdatedEvent>.broadcast();
  final _taskStatusChangedCtrl = StreamController<TaskStatusChangedEvent>.broadcast();
  final _taskAssignedCtrl = StreamController<TaskAssignedEvent>.broadcast();
  final _taskDeletedCtrl = StreamController<TaskDeletedEvent>.broadcast();
  final _commentAddedCtrl = StreamController<CommentAddedEvent>.broadcast();
  final _commentDeletedCtrl = StreamController<CommentDeletedEvent>.broadcast();
  final _presenceChangedCtrl = StreamController<PresenceChangedEvent>.broadcast();

  int? joinedWorkspaceId;
  int? leftWorkspaceId;

  @override
  Stream<TaskCreatedEvent> get taskCreated => _taskCreatedCtrl.stream;
  @override
  Stream<TaskUpdatedEvent> get taskUpdated => _taskUpdatedCtrl.stream;
  @override
  Stream<TaskStatusChangedEvent> get taskStatusChanged => _taskStatusChangedCtrl.stream;
  @override
  Stream<TaskAssignedEvent> get taskAssigned => _taskAssignedCtrl.stream;
  @override
  Stream<TaskDeletedEvent> get taskDeleted => _taskDeletedCtrl.stream;
  @override
  Stream<CommentAddedEvent> get commentAdded => _commentAddedCtrl.stream;
  @override
  Stream<CommentDeletedEvent> get commentDeleted => _commentDeletedCtrl.stream;
  @override
  Stream<PresenceChangedEvent> get presenceChanged => _presenceChangedCtrl.stream;

  @override
  Future<void> joinWorkspace(int workspaceId) async {
    joinedWorkspaceId = workspaceId;
  }

  @override
  Future<void> leaveWorkspace(int workspaceId) async {
    leftWorkspaceId = workspaceId;
  }

  void emitTaskCreated(TaskDto task) => _taskCreatedCtrl.add(task);
  void emitTaskUpdated(TaskDto task) => _taskUpdatedCtrl.add(task);
  void emitTaskStatusChanged(TaskDto task) => _taskStatusChangedCtrl.add(task);
  void emitTaskAssigned(TaskDto task) => _taskAssignedCtrl.add(task);
  void emitTaskDeleted(TaskDeletedEvent event) => _taskDeletedCtrl.add(event);
  void emitCommentAdded(CommentDto comment) => _commentAddedCtrl.add(comment);
  void emitCommentDeleted(CommentDeletedEvent event) => _commentDeletedCtrl.add(event);

  void disposeStreams() {
    _taskCreatedCtrl.close();
    _taskUpdatedCtrl.close();
    _taskStatusChangedCtrl.close();
    _taskAssignedCtrl.close();
    _taskDeletedCtrl.close();
    _commentAddedCtrl.close();
    _commentDeletedCtrl.close();
    _presenceChangedCtrl.close();
  }
}

void main() {
  late _FakeSignalRService signalR;
  late KanbanCubit cubit;

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
    signalR = _FakeSignalRService();
    cubit = KanbanCubit(
      TestTaskRepository([sampleTask]),
      TestProjectRepository(testProject),
      signalR,
    );
  });

  tearDown(() {
    cubit.close();
    signalR.disposeStreams();
  });

  test('loadTasks joins workspace and subscribes to SignalR', () async {
    await cubit.loadTasks(1);
    expect(signalR.joinedWorkspaceId, 10);
    expect(cubit.state, isA<KanbanLoaded>());
  });

  test('realtime taskCreated adds task to loaded list', () async {
    await cubit.loadTasks(1);
    const newTask = TaskDto(id: 102, projectId: 1, title: 'New Realtime Task');
    signalR.emitTaskCreated(newTask);
    await pumpEventQueue();

    final loaded = cubit.state as KanbanLoaded;
    expect(loaded.allTasks.length, 2);
    expect(loaded.allTasks.any((t) => t.id == 102), isTrue);
  });

  test('realtime taskStatusChanged updates task status', () async {
    await cubit.loadTasks(1);
    final updated = sampleTask.copyWith(status: 'InProgress');
    signalR.emitTaskStatusChanged(updated);
    await pumpEventQueue();

    final loaded = cubit.state as KanbanLoaded;
    expect(loaded.allTasks.first.status, 'InProgress');
  });

  test('realtime taskAssigned updates assignee', () async {
    await cubit.loadTasks(1);
    final updated = sampleTask.copyWith(assigneeId: 'u99', assigneeName: 'Alice');
    signalR.emitTaskAssigned(updated);
    await pumpEventQueue();

    final loaded = cubit.state as KanbanLoaded;
    expect(loaded.allTasks.first.assigneeName, 'Alice');
  });

  test('realtime commentAdded and commentDeleted modify commentCount', () async {
    await cubit.loadTasks(1);
    signalR.emitCommentAdded(CommentDto(
      id: 1,
      taskId: 101,
      authorId: 'u1',
      authorName: 'User',
      content: 'Hi',
      createdAt: DateTime.now(),
    ));
    await pumpEventQueue();

    var loaded = cubit.state as KanbanLoaded;
    expect(loaded.allTasks.first.commentCount, 1);

    signalR.emitCommentDeleted(const CommentDeletedEvent(taskId: 101, commentId: 1));
    await pumpEventQueue();

    loaded = cubit.state as KanbanLoaded;
    expect(loaded.allTasks.first.commentCount, 0);
  });

  test('realtime taskDeleted removes task and triggers empty state when last task removed', () async {
    await cubit.loadTasks(1);
    signalR.emitTaskDeleted(const TaskDeletedEvent(taskId: 101, projectId: 1));
    await pumpEventQueue();

    final isEmpty = cubit.state.maybeWhen(empty: (_, _) => true, orElse: () => false);
    expect(isEmpty, isTrue);
  });
}
