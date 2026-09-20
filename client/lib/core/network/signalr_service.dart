import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:signalr_netcore/signalr_client.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/network/signalr_events.dart';
import 'package:client/core/storage/secure_storage_service.dart';
import 'package:client/features/comments/data/models/comment_dto.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';

@lazySingleton
class SignalRService {
  SignalRService(this._secureStorage);

  final SecureStorageService _secureStorage;
  HubConnection? _connection;
  int? _currentWorkspaceId;

  final _taskCreated = StreamController<TaskCreatedEvent>.broadcast();
  final _taskUpdated = StreamController<TaskUpdatedEvent>.broadcast();
  final _taskStatusChanged =
      StreamController<TaskStatusChangedEvent>.broadcast();
  final _taskAssigned = StreamController<TaskAssignedEvent>.broadcast();
  final _taskDeleted = StreamController<TaskDeletedEvent>.broadcast();
  final _commentAdded = StreamController<CommentAddedEvent>.broadcast();
  final _commentDeleted = StreamController<CommentDeletedEvent>.broadcast();
  final _presenceChanged = StreamController<PresenceChangedEvent>.broadcast();

  Stream<TaskCreatedEvent> get taskCreated => _taskCreated.stream;
  Stream<TaskUpdatedEvent> get taskUpdated => _taskUpdated.stream;
  Stream<TaskStatusChangedEvent> get taskStatusChanged =>
      _taskStatusChanged.stream;
  Stream<TaskAssignedEvent> get taskAssigned => _taskAssigned.stream;
  Stream<TaskDeletedEvent> get taskDeleted => _taskDeleted.stream;
  Stream<CommentAddedEvent> get commentAdded => _commentAdded.stream;
  Stream<CommentDeletedEvent> get commentDeleted => _commentDeleted.stream;
  Stream<PresenceChangedEvent> get presenceChanged => _presenceChanged.stream;

  Future<void> ensureConnected() async {
    if (_connection?.state == HubConnectionState.Connected) return;

    final token = await _secureStorage.getAccessToken();
    if (token == null) return;

    final url = ApiConstants.workspaceHubUrl;
    final options = HttpConnectionOptions(
      accessTokenFactory: () async => (await _secureStorage.getAccessToken()) ?? '',
    );

    _connection = HubConnectionBuilder()
        .withUrl(url, options: options)
        .withAutomaticReconnect()
        .build();

    _registerHandlers();

    try {
      await _connection!.start();
      if (_currentWorkspaceId != null) {
        await joinWorkspace(_currentWorkspaceId!);
      }
    } catch (e) {
      debugPrint('[SignalRService] Error connecting: $e');
    }
  }

  void _registerHandlers() {
    final conn = _connection;
    if (conn == null) return;

    conn.on('TaskCreated', (args) {
      if (args != null && args.isNotEmpty) {
        final map = Map<String, dynamic>.from(args[0] as Map);
        _taskCreated.add(TaskDto.fromJson(map));
      }
    });

    conn.on('TaskUpdated', (args) {
      if (args != null && args.isNotEmpty) {
        final map = Map<String, dynamic>.from(args[0] as Map);
        _taskUpdated.add(TaskDto.fromJson(map));
      }
    });

    conn.on('TaskStatusChanged', (args) {
      if (args != null && args.isNotEmpty) {
        final map = Map<String, dynamic>.from(args[0] as Map);
        _taskStatusChanged.add(TaskDto.fromJson(map));
      }
    });

    conn.on('TaskAssigned', (args) {
      if (args != null && args.isNotEmpty) {
        final map = Map<String, dynamic>.from(args[0] as Map);
        _taskAssigned.add(TaskDto.fromJson(map));
      }
    });

    conn.on('TaskDeleted', (args) {
      if (args != null && args.isNotEmpty) {
        final map = Map<String, dynamic>.from(args[0] as Map);
        _taskDeleted.add(TaskDeletedEvent.fromJson(map));
      }
    });

    conn.on('CommentAdded', (args) {
      if (args != null && args.isNotEmpty) {
        final map = Map<String, dynamic>.from(args[0] as Map);
        _commentAdded.add(CommentDto.fromJson(map));
      }
    });

    conn.on('CommentDeleted', (args) {
      if (args != null && args.isNotEmpty) {
        final map = Map<String, dynamic>.from(args[0] as Map);
        _commentDeleted.add(CommentDeletedEvent.fromJson(map));
      }
    });

    conn.on('PresenceChanged', (args) {
      if (args != null && args.isNotEmpty) {
        final map = Map<String, dynamic>.from(args[0] as Map);
        _presenceChanged.add(PresenceChangedEvent.fromJson(map));
      }
    });

    conn.onreconnected(({connectionId}) async {
      if (_currentWorkspaceId != null) {
        await joinWorkspace(_currentWorkspaceId!);
      }
    });
  }

  Future<void> joinWorkspace(int workspaceId) async {
    _currentWorkspaceId = workspaceId;
    if (_connection?.state != HubConnectionState.Connected) {
      await ensureConnected();
      return;
    }
    try {
      await _connection?.invoke('JoinWorkspace', args: [workspaceId]);
    } catch (e) {
      debugPrint('[SignalRService] JoinWorkspace error: $e');
    }
  }

  Future<void> leaveWorkspace(int workspaceId) async {
    if (_currentWorkspaceId == workspaceId) {
      _currentWorkspaceId = null;
    }
    if (_connection?.state == HubConnectionState.Connected) {
      try {
        await _connection?.invoke('LeaveWorkspace', args: [workspaceId]);
      } catch (e) {
        debugPrint('[SignalRService] LeaveWorkspace error: $e');
      }
    }
  }

  Future<void> disconnect() async {
    _currentWorkspaceId = null;
    if (_connection != null) {
      await _connection!.stop();
      _connection = null;
    }
  }

  void dispose() {
    disconnect();
    _taskCreated.close();
    _taskUpdated.close();
    _taskStatusChanged.close();
    _taskAssigned.close();
    _taskDeleted.close();
    _commentAdded.close();
    _commentDeleted.close();
    _presenceChanged.close();
  }
}
