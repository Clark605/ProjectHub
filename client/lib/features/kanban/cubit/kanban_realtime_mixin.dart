import 'dart:async';

import 'package:client/core/network/signalr_events.dart';
import 'package:client/core/network/signalr_service.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';

mixin KanbanRealtimeMixin {
  SignalRService? get signalRService;
  int? get currentProjectId;

  StreamSubscription<TaskCreatedEvent>? _taskCreatedSub;
  StreamSubscription<TaskUpdatedEvent>? _taskUpdatedSub;
  StreamSubscription<TaskStatusChangedEvent>? _taskStatusChangedSub;
  StreamSubscription<TaskAssignedEvent>? _taskAssignedSub;
  StreamSubscription<TaskDeletedEvent>? _taskDeletedSub;
  StreamSubscription<CommentAddedEvent>? _commentAddedSub;
  StreamSubscription<CommentDeletedEvent>? _commentDeletedSub;

  void onRealtimeTaskCreated(TaskDto task);
  void onRealtimeTaskUpdated(TaskDto task);
  void onRealtimeTaskStatusChanged(int taskId, String newStatus);
  void onRealtimeTaskAssigned(int taskId, String? assigneeId, String? assigneeName);
  void onRealtimeTaskDeleted(int taskId);
  void onRealtimeCommentAdded(int taskId);
  void onRealtimeCommentDeleted(int taskId);

  void subscribeToRealtime() {
    unsubscribeFromRealtime();
    final service = signalRService;
    if (service == null) return;

    _taskCreatedSub = service.taskCreated.listen((task) {
      if (currentProjectId != null && task.projectId == currentProjectId) {
        onRealtimeTaskCreated(task);
      }
    });

    _taskUpdatedSub = service.taskUpdated.listen((task) {
      if (currentProjectId != null && task.projectId == currentProjectId) {
        onRealtimeTaskUpdated(task);
      }
    });

    _taskStatusChangedSub = service.taskStatusChanged.listen((task) {
      if (currentProjectId != null && task.projectId == currentProjectId) {
        onRealtimeTaskStatusChanged(task.id, task.status);
      }
    });

    _taskAssignedSub = service.taskAssigned.listen((task) {
      if (currentProjectId != null && task.projectId == currentProjectId) {
        onRealtimeTaskAssigned(task.id, task.assigneeId, task.assigneeName);
      }
    });

    _taskDeletedSub = service.taskDeleted.listen((event) {
      if (currentProjectId != null && event.projectId == currentProjectId) {
        onRealtimeTaskDeleted(event.taskId);
      }
    });

    _commentAddedSub = service.commentAdded.listen((comment) {
      onRealtimeCommentAdded(comment.taskId);
    });

    _commentDeletedSub = service.commentDeleted.listen((event) {
      onRealtimeCommentDeleted(event.taskId);
    });
  }

  void unsubscribeFromRealtime() {
    _taskCreatedSub?.cancel();
    _taskUpdatedSub?.cancel();
    _taskStatusChangedSub?.cancel();
    _taskAssignedSub?.cancel();
    _taskDeletedSub?.cancel();
    _commentAddedSub?.cancel();
    _commentDeletedSub?.cancel();
    _taskCreatedSub = null;
    _taskUpdatedSub = null;
    _taskStatusChangedSub = null;
    _taskAssignedSub = null;
    _taskDeletedSub = null;
    _commentAddedSub = null;
    _commentDeletedSub = null;
  }
}
