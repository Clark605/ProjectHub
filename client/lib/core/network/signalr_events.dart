import 'package:client/features/comments/data/models/comment_dto.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';

class TaskDeletedEvent {
  const TaskDeletedEvent({required this.taskId, required this.projectId});

  factory TaskDeletedEvent.fromJson(Map<String, dynamic> json) {
    return TaskDeletedEvent(
      taskId: (json['taskId'] ?? json['TaskId']) as int,
      projectId: (json['projectId'] ?? json['ProjectId']) as int,
    );
  }

  final int taskId;
  final int projectId;
}

class CommentDeletedEvent {
  const CommentDeletedEvent({required this.taskId, required this.commentId});

  factory CommentDeletedEvent.fromJson(Map<String, dynamic> json) {
    return CommentDeletedEvent(
      taskId: (json['taskId'] ?? json['TaskId']) as int,
      commentId: (json['commentId'] ?? json['CommentId']) as int,
    );
  }

  final int taskId;
  final int commentId;
}

class PresenceChangedEvent {
  const PresenceChangedEvent({
    required this.workspaceId,
    required this.onlineUserIds,
  });

  factory PresenceChangedEvent.fromJson(Map<String, dynamic> json) {
    final rawList = json['onlineUserIds'] ?? json['OnlineUserIds'];
    final list = rawList is List
        ? rawList.map((e) => e.toString()).toList()
        : <String>[];
    return PresenceChangedEvent(
      workspaceId: (json['workspaceId'] ?? json['WorkspaceId'] ?? 0) as int,
      onlineUserIds: list,
    );
  }

  final int workspaceId;
  final List<String> onlineUserIds;
}

typedef TaskCreatedEvent = TaskDto;
typedef TaskUpdatedEvent = TaskDto;
typedef TaskStatusChangedEvent = TaskDto;
typedef TaskAssignedEvent = TaskDto;
typedef CommentAddedEvent = CommentDto;
