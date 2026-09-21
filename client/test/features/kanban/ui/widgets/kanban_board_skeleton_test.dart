import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/kanban/ui/widgets/kanban_board_skeleton.dart';

void main() {
  group('KanbanBoardSkeleton', () {
    testWidgets('renders on mobile viewport without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KanbanBoardSkeleton(),
          ),
        ),
      );

      expect(find.byType(KanbanBoardSkeleton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders on desktop viewport without overflow', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KanbanBoardSkeleton(),
          ),
        ),
      );

      expect(find.byType(KanbanBoardSkeleton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in light theme without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: KanbanBoardSkeleton(),
          ),
        ),
      );

      expect(find.byType(KanbanBoardSkeleton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
