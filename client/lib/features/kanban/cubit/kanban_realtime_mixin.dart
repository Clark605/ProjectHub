import 'dart:async';

import 'package:client/core/network/signalr_events.dart';
import 'package:client/core/network/signalr_service.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';

mixin KanbanRealtimeMixin {
  SignalRService? get signalRService;
  int? get currentProjectId;
  KanbanState get state;
  void emit(KanbanState state);
  void emitLoaded(List<TaskDto> allTasks, {String? errorMessage});
  void updateTaskInLoaded(int taskId, TaskDto updated);
  bool get isArchived;

  StreamSubscription<TaskCreatedEvent>? _taskCreatedSub;
  StreamSubscription<TaskUpdatedEvent>? _taskUpdatedSub;
  StreamSubscription<TaskStatusChangedEvent>? _taskStatusChangedSub;
  StreamSubscription<TaskAssignedEvent>? _taskAssignedSub;
  StreamSubscription<TaskDeletedEvent>? _taskDeletedSub;
  StreamSubscription<CommentAddedEvent>? _commentAddedSub;
  StreamSubscription<CommentDeletedEvent>? _commentDeletedSub;

  void onRealtimeTaskCreated(TaskDto task) {
    state.maybeWhen(
      loaded: (pId, tasks, allTasks, arch, sF, pF, aF, err) {
        if (!allTasks.any((t) => t.id == task.id)) {
          emitLoaded([task, ...allTasks]);
        }
      },
      empty: (_, _) => emitLoaded([task]),
      orElse: () {},
    );
  }

  void onRealtimeTaskUpdated(TaskDto task) => updateTaskInLoaded(task.id, task);

  void onRealtimeTaskStatusChanged(int taskId, String newStatus) {
    final current = state;
    if (current is KanbanLoaded) {
      final t = current.allTasks.where((x) => x.id == taskId).firstOrNull;
      if (t != null && t.status != newStatus) {
        updateTaskInLoaded(taskId, t.copyWith(status: newStatus));
      }
    }
  }

  void onRealtimeTaskAssigned(
    int taskId,
    String? assigneeId,
    String? assigneeName,
  ) {
    final current = state;
    if (current is KanbanLoaded) {
      final t = current.allTasks.where((x) => x.id == taskId).firstOrNull;
      if (t != null) {
        updateTaskInLoaded(
          taskId,
          t.copyWith(assigneeId: assigneeId, assigneeName: assigneeName),
        );
      }
    }
  }

  void onRealtimeTaskDeleted(int taskId) {
    final current = state;
    if (current is KanbanLoaded) {
      final remaining = current.allTasks.where((t) => t.id != taskId).toList();
      if (remaining.isEmpty) {
        emit(
          KanbanState.empty(
            projectId: currentProjectId ?? 0,
            isArchived: isArchived,
          ),
        );
      } else {
        emitLoaded(remaining);
      }
    }
  }

  void onRealtimeCommentAdded(int taskId) {
    final current = state;
    if (current is KanbanLoaded) {
      final t = current.allTasks.where((x) => x.id == taskId).firstOrNull;
      if (t != null) {
        updateTaskInLoaded(
          taskId,
          t.copyWith(commentCount: t.commentCount + 1),
        );
      }
    }
  }

  void onRealtimeCommentDeleted(int taskId) {
    final current = state;
    if (current is KanbanLoaded) {
      final t = current.allTasks.where((x) => x.id == taskId).firstOrNull;
      if (t != null && t.commentCount > 0) {
        updateTaskInLoaded(
          taskId,
          t.copyWith(commentCount: t.commentCount - 1),
        );
      }
    }
  }

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
