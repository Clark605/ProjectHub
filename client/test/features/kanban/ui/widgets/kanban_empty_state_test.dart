import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/features/kanban/ui/widgets/board/kanban_empty_state.dart';
import 'package:client/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildWidget({bool isArchived = false, VoidCallback? onCreateTask}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: KanbanEmptyState(
          isArchived: isArchived,
          onCreateTask: onCreateTask,
        ),
      ),
    );
  }

  group('KanbanEmptyState', () {
    testWidgets('renders active board empty state with CTA and handles tap', (
      tester,
    ) async {
      bool created = false;
      await tester.pumpWidget(
        buildWidget(isArchived: false, onCreateTask: () => created = true),
      );

      expect(find.text('Board is Empty'), findsOneWidget);
      expect(
        find.text(
          'Start organizing your workflow by creating the first task for this project.',
        ),
        findsOneWidget,
      );
      expect(find.text('Create First Task'), findsOneWidget);

      await tester.tap(find.text('Create First Task'));
      await tester.pump();
      expect(created, isTrue);
    });

    testWidgets('renders archived project empty state without CTA button', (
      tester,
    ) async {
      bool created = false;
      await tester.pumpWidget(
        buildWidget(isArchived: true, onCreateTask: () => created = true),
      );

      expect(find.text('No Tasks'), findsOneWidget);
      expect(
        find.text('This project is archived and has no tasks recorded.'),
        findsOneWidget,
      );
      expect(find.text('Create First Task'), findsNothing);
      expect(created, isFalse);
    });

    testWidgets('does not show CTA button when onCreateTask is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(isArchived: false, onCreateTask: null),
      );

      expect(find.text('Board is Empty'), findsOneWidget);
      expect(find.text('Create First Task'), findsNothing);
    });
  });
}
