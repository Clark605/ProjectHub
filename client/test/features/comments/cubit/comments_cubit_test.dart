import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/network/signalr_events.dart';
import 'package:client/core/network/signalr_service.dart';
import 'package:client/features/comments/cubit/comments_cubit.dart';
import 'package:client/features/comments/cubit/comments_state.dart';
import 'package:client/features/comments/data/comment_repository.dart';
import 'package:client/features/comments/data/models/comment_dto.dart';

class MockCommentRepository extends Mock implements CommentRepository {}

class MockSignalRService extends Mock implements SignalRService {}

void main() {
  group('CommentsCubit', () {
    late MockCommentRepository repo;
    late MockSignalRService signalR;
    late StreamController<CommentAddedEvent> commentAddedCtrl;
    late StreamController<CommentDeletedEvent> commentDeletedCtrl;

    const taskId = 42;
    final initialComment = CommentDto(
      id: 1,
      taskId: taskId,
      authorId: 'u1',
      authorName: 'Test User',
      content: 'Initial comment',
      createdAt: DateTime(2026, 1, 1),
    );

    setUp(() {
      repo = MockCommentRepository();
      signalR = MockSignalRService();
      commentAddedCtrl = StreamController<CommentAddedEvent>.broadcast();
      commentDeletedCtrl = StreamController<CommentDeletedEvent>.broadcast();

      when(() => signalR.commentAdded).thenAnswer((_) => commentAddedCtrl.stream);
      when(() => signalR.commentDeleted).thenAnswer((_) => commentDeletedCtrl.stream);
    });

    tearDown(() async {
      await commentAddedCtrl.close();
      await commentDeletedCtrl.close();
    });

    blocTest<CommentsCubit, CommentsState>(
      'loads comments on initialization and emits loaded state',
      build: () {
        when(() => repo.getComments(taskId)).thenAnswer((_) async => []);
        return CommentsCubit(
          taskId: taskId,
          repository: repo,
          signalRService: signalR,
        );
      },
      expect: () => [
        const CommentsState.loaded(comments: []),
      ],
      verify: (_) {
        verify(() => repo.getComments(taskId)).called(1);
      },
    );

    blocTest<CommentsCubit, CommentsState>(
      'addComment creates and appends new comment',
      build: () {
        when(() => repo.getComments(taskId)).thenAnswer((_) async => []);
        when(
          () => repo.createComment(taskId, 'Hello team'),
        ).thenAnswer(
          (_) async => CommentDto(
            id: 2,
            taskId: taskId,
            authorId: 'u1',
            authorName: 'Test User',
            content: 'Hello team',
            createdAt: DateTime(2026, 1, 1),
          ),
        );
        return CommentsCubit(
          taskId: taskId,
          repository: repo,
          signalRService: signalR,
        );
      },
      act: (cubit) async {
        await pumpEventQueue();
        await cubit.addComment('Hello team');
      },
      skip: 1, // skip initial loaded from loadComments in constructor
      expect: () => [
        const CommentsState.loaded(comments: [], isSending: true),
        isA<CommentsState>().having(
          (s) => s.maybeWhen(
            loaded: (comments, isSending, _) =>
                comments.length == 1 &&
                comments.first.content == 'Hello team' &&
                !isSending,
            orElse: () => false,
          ),
          'loaded with new comment',
          isTrue,
        ),
      ],
      verify: (_) {
        verify(() => repo.createComment(taskId, 'Hello team')).called(1);
      },
    );

    blocTest<CommentsCubit, CommentsState>(
      'deleteComment removes comment from state',
      build: () {
        when(
          () => repo.getComments(taskId),
        ).thenAnswer((_) async => [initialComment]);
        when(() => repo.deleteComment(1)).thenAnswer((_) async {});
        return CommentsCubit(
          taskId: taskId,
          repository: repo,
          signalRService: signalR,
        );
      },
      act: (cubit) async {
        await pumpEventQueue();
        await cubit.deleteComment(1);
      },
      skip: 1,
      expect: () => [
        const CommentsState.loaded(comments: []),
      ],
      verify: (_) {
        verify(() => repo.deleteComment(1)).called(1);
      },
    );

    blocTest<CommentsCubit, CommentsState>(
      'reacts to real-time commentAdded and commentDeleted events',
      build: () {
        when(() => repo.getComments(taskId)).thenAnswer((_) async => []);
        return CommentsCubit(
          taskId: taskId,
          repository: repo,
          signalRService: signalR,
        );
      },
      act: (cubit) async {
        await pumpEventQueue();
        final remoteComment = CommentDto(
          id: 99,
          taskId: taskId,
          authorId: 'peer_user',
          authorName: 'Peer Collaborator',
          content: 'Live update from peer',
          createdAt: DateTime(2026, 1, 1),
        );
        commentAddedCtrl.add(remoteComment);
        await pumpEventQueue();
        commentDeletedCtrl.add(
          const CommentDeletedEvent(taskId: taskId, commentId: 99),
        );
      },
      skip: 1,
      expect: () => [
        isA<CommentsState>().having(
          (s) => s.maybeWhen(
            loaded: (comments, _, _) =>
                comments.any((c) => c.id == 99),
            orElse: () => false,
          ),
          'loaded with remote comment',
          isTrue,
        ),
        const CommentsState.loaded(comments: []),
      ],
    );
  });
}
