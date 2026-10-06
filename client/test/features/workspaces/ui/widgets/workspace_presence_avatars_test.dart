import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/network/signalr_events.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_avatar_item.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_presence_avatars.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_presence_sheet.dart';

import '../../../../helpers/mock_repositories.dart';

void main() {
  late MockSignalRService mockSignalR;
  late StreamController<PresenceChangedEvent> presenceController;

  setUp(() {
    mockSignalR = MockSignalRService();
    presenceController = StreamController<PresenceChangedEvent>.broadcast();
    when(() => mockSignalR.presenceChanged)
        .thenAnswer((_) => presenceController.stream);
    when(() => mockSignalR.joinWorkspace(any())).thenAnswer((_) async {});
  });

  tearDown(() {
    presenceController.close();
  });

  testWidgets(
    'WorkspacePresenceAvatars renders nothing when online count is 0',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkspacePresenceAvatars(
              workspaceId: 1,
              signalRService: mockSignalR,
            ),
          ),
        ),
      );

      expect(find.byType(WorkspaceAvatarItem), findsNothing);
    },
  );

  testWidgets(
    'WorkspacePresenceAvatars renders avatar with initials when users are online',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkspacePresenceAvatars(
              workspaceId: 1,
              signalRService: mockSignalR,
            ),
          ),
        ),
      );

      presenceController.add(
        const PresenceChangedEvent(
          workspaceId: 1,
          onlineUserIds: ['user-alpha', 'user-beta'],
        ),
      );
      await tester.pump();

      expect(find.byType(WorkspaceAvatarItem), findsNWidgets(2));
    },
  );

  testWidgets(
    'WorkspacePresenceAvatars renders +N overflow badge when > 3 users online',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkspacePresenceAvatars(
              workspaceId: 1,
              signalRService: mockSignalR,
            ),
          ),
        ),
      );

      presenceController.add(
        const PresenceChangedEvent(
          workspaceId: 1,
          onlineUserIds: ['u1', 'u2', 'u3', 'u4', 'u5'],
        ),
      );
      await tester.pump();

      // 3 visible avatars + "+2" badge
      expect(find.byType(WorkspaceAvatarItem), findsNWidgets(3));
      expect(find.text('+2'), findsOneWidget);
    },
  );

  testWidgets('Tapping WorkspacePresenceAvatars opens WorkspacePresenceSheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkspacePresenceAvatars(
            workspaceId: 1,
            signalRService: mockSignalR,
          ),
        ),
      ),
    );

    presenceController.add(
      const PresenceChangedEvent(workspaceId: 1, onlineUserIds: ['user-1']),
    );
    await tester.pump();

    await tester.tap(find.byType(WorkspacePresenceAvatars));
    await tester.pumpAndSettle();

    expect(find.byType(WorkspacePresenceSheet), findsOneWidget);
  });
}
