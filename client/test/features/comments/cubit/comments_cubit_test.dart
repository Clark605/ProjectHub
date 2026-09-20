import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/network/signalr_events.dart';
import 'package:client/core/network/signalr_service.dart';
import 'package:client/core/storage/secure_storage_service.dart';
import 'package:client/features/comments/cubit/comments_cubit.dart';
import 'package:client/features/comments/cubit/comments_state.dart';
import 'package:client/features/comments/data/comment_repository.dart';
import 'package:client/features/comments/data/models/comment_dto.dart';

class FakeCommentRepository implements CommentRepository {
  List<CommentDto> comments = [];

  @override
  Future<List<CommentDto>> getComments(int taskId) async {
    return List.from(comments);
  }

  @override
  Future<CommentDto> createComment(int taskId, String content) async {
    final newComment = CommentDto(
      id: comments.length + 1,
      taskId: taskId,
      authorId: 'user_1',
      authorName: 'Test User',
      content: content,
      createdAt: DateTime.now(),
    );
    comments.add(newComment);
    return newComment;
  }

  @override
  Future<CommentDto> updateComment(int commentId, String content) async {
    final index = comments.indexWhere((c) => c.id == commentId);
    final updated = comments[index].copyWith(
      content: content,
      updatedAt: DateTime.now(),
    );
    comments[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteComment(int commentId) async {
    comments.removeWhere((c) => c.id == commentId);
  }
}

class FakeSignalRService extends SignalRService {
  FakeSignalRService() : super(SecureStorageService());

  final _taskCreatedCtrl = StreamController<TaskCreatedEvent>.broadcast();
  final _taskUpdatedCtrl = StreamController<TaskUpdatedEvent>.broadcast();
  final _taskStatusChangedCtrl =
      StreamController<TaskStatusChangedEvent>.broadcast();
  final _taskAssignedCtrl = StreamController<TaskAssignedEvent>.broadcast();
  final _taskDeletedCtrl = StreamController<TaskDeletedEvent>.broadcast();
  final _commentAddedCtrl = StreamController<CommentAddedEvent>.broadcast();
  final _commentDeletedCtrl = StreamController<CommentDeletedEvent>.broadcast();
  final _presenceChangedCtrl =
      StreamController<PresenceChangedEvent>.broadcast();

  @override
  Stream<TaskCreatedEvent> get taskCreated => _taskCreatedCtrl.stream;
  @override
  Stream<TaskUpdatedEvent> get taskUpdated => _taskUpdatedCtrl.stream;
  @override
  Stream<TaskStatusChangedEvent> get taskStatusChanged =>
      _taskStatusChangedCtrl.stream;
  @override
  Stream<TaskAssignedEvent> get taskAssigned => _taskAssignedCtrl.stream;
  @override
  Stream<TaskDeletedEvent> get taskDeleted => _taskDeletedCtrl.stream;
  @override
  Stream<CommentAddedEvent> get commentAdded => _commentAddedCtrl.stream;
  @override
  Stream<CommentDeletedEvent> get commentDeleted => _commentDeletedCtrl.stream;
  @override
  Stream<PresenceChangedEvent> get presenceChanged =>
      _presenceChangedCtrl.stream;

  void emitCommentAdded(CommentDto comment) => _commentAddedCtrl.add(comment);
  void emitCommentDeleted(CommentDeletedEvent event) =>
      _commentDeletedCtrl.add(event);

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
  late FakeCommentRepository repo;
  late FakeSignalRService signalR;
  late CommentsCubit cubit;

  setUp(() {
    repo = FakeCommentRepository();
    signalR = FakeSignalRService();
    cubit = CommentsCubit(
      taskId: 42,
      repository: repo,
      signalRService: signalR,
    );
  });

  tearDown(() {
    cubit.close();
    signalR.disposeStreams();
  });

  test('loads comments and emits loaded state', () async {
    await pumpEventQueue();
    final loaded = cubit.state.mapOrNull(loaded: (l) => l);
    expect(loaded, isNotNull);
    expect(loaded!.comments, isEmpty);
    expect(loaded.isSending, isFalse);
  });

  test('addComment creates and appends new comment', () async {
    await pumpEventQueue();
    final success = await cubit.addComment('Hello team');
    expect(success, isTrue);

    final loaded = cubit.state.mapOrNull(loaded: (l) => l);
    expect(loaded, isNotNull);
    expect(loaded!.comments.length, 1);
    expect(loaded.comments.first.content, 'Hello team');
  });

  test('deleteComment removes comment from state', () async {
    await pumpEventQueue();
    await cubit.addComment('First comment');
    await cubit.deleteComment(1);

    final loaded = cubit.state.mapOrNull(loaded: (l) => l);
    expect(loaded, isNotNull);
    expect(loaded!.comments, isEmpty);
  });

  test('reacts to real-time commentAdded and commentDeleted events', () async {
    await pumpEventQueue();

    final remoteComment = CommentDto(
      id: 99,
      taskId: 42,
      authorId: 'peer_user',
      authorName: 'Peer Collaborator',
      content: 'Live update from peer',
      createdAt: DateTime.now(),
    );

    signalR.emitCommentAdded(remoteComment);
    await pumpEventQueue();

    final withAdded = cubit.state.mapOrNull(loaded: (l) => l);
    expect(withAdded, isNotNull);
    expect(withAdded!.comments.any((c) => c.id == 99), isTrue);

    signalR.emitCommentDeleted(
      const CommentDeletedEvent(taskId: 42, commentId: 99),
    );
    await pumpEventQueue();

    final withDeleted = cubit.state.mapOrNull(loaded: (l) => l);
    expect(withDeleted, isNotNull);
    expect(withDeleted!.comments.any((c) => c.id == 99), isFalse);
  });
}
