import 'package:client/core/theme/light_theme.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/ui/widgets/card/kanban_task_card.dart';
import 'package:client/features/kanban/ui/widgets/card/kanban_task_card_footer.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_priority.dart';
import 'package:client/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleTag = TagDto(
    id: 99,
    workspaceId: 1,
    name: 'Frontend',
    color: '#ff0055',
  );

  const sampleTask = TaskDto(
    id: 1,
    projectId: 10,
    title: 'Optimize layout passes',
    priority: 'Urgent',
    status: 'InProgress',
    tags: [sampleTag],
  );

  testWidgets(
    'KanbanTaskCard renders title, tags, and has 48dp touch target on PopupMenuButton',
    (tester) async {
      TagDto? tappedTag;
      bool deleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: KanbanTaskCard(
              task: sampleTask,
              onTagTap: (t) => tappedTag = t,
              onDelete: () => deleteCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Optimize layout passes'), findsOneWidget);
      expect(find.text('Frontend'), findsOneWidget);

      // Verify PopupMenuButton constraints meet 48x48 dp touch target
      final popupButtonFinder = find.byType(PopupMenuButton<String>);
      expect(popupButtonFinder, findsOneWidget);
      final popupButton = tester.widget<PopupMenuButton<String>>(
        popupButtonFinder,
      );
      expect(popupButton.constraints?.minWidth, greaterThanOrEqualTo(48.0));
      expect(popupButton.constraints?.minHeight, greaterThanOrEqualTo(48.0));

      // Tap the tag chip
      await tester.tap(find.text('Frontend'));
      await tester.pump();
      expect(tappedTag, isNotNull);
      expect(tappedTag!.id, 99);

      // Open popup menu and tap delete
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(deleteCalled, isTrue);
    },
  );

  testWidgets(
    'KanbanTaskCard safely no-ops without callbacks when BlocProvider is omitted',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: KanbanTaskCard(task: sampleTask)),
        ),
      );

      // Tap card
      await tester.tap(find.text('Optimize layout passes'));
      await tester.pump();

      // Long press card
      await tester.longPress(find.text('Optimize layout passes'));
      await tester.pump();

      // Tap tag chip
      await tester.tap(find.text('Frontend'));
      await tester.pump();

      // Tap popup menu actions
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move Task'));
      await tester.pumpAndSettle();

      // No crash/exception thrown
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'KanbanTaskCard toggles filter on tag tap via KanbanCubit when callbacks are omitted',
    (tester) async {
      final mockRepo = createMockTaskRepository(tasks: [sampleTask]);
      final mockProjectRepo = createMockProjectRepository(
        project: const ProjectDto(
          id: 10,
          workspaceId: 1,
          name: 'P1',
          status: 'Active',
        ),
      );
      final cubit = KanbanCubit(mockRepo, mockProjectRepo);
      await cubit.loadTasks(10);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: cubit,
            child: const Scaffold(body: KanbanTaskCard(task: sampleTask)),
          ),
        ),
      );

      expect(cubit.tagFilter, isNull);

      // Tap tag -> sets filter
      await tester.tap(find.text('Frontend'));
      await tester.pump();
      expect(cubit.tagFilter, 99);

      // Tap tag again -> clears filter
      await tester.tap(find.text('Frontend'));
      await tester.pump();
      expect(cubit.tagFilter, isNull);
    },
  );

  testWidgets(
    'KanbanTaskCardFooter renders without overflow at text scale 1.5 in Arabic',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 240,
                child: KanbanTaskCardFooter(
                  priority: TaskPriority.urgent,
                  dueDate: DateTime(2026, 10, 15),
                  isOverdue: true,
                  assigneeName: 'أحمد محمد',
                  commentCount: 12,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('عاجلة'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    },
  );

  testWidgets(
    'KanbanTaskCardFooter renders unassigned avatar when assigneeName is null',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: KanbanTaskCardFooter(isOverdue: false, assigneeName: null),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is Tooltip && w.message == 'Unassigned',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'KanbanTaskCardFooter renders assigned avatar when assigneeName is present',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: KanbanTaskCardFooter(
              isOverdue: false,
              assigneeName: 'Clark Kent',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('CK'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is Tooltip && (w.message?.contains('Clark Kent') ?? false),
        ),
        findsOneWidget,
      );
    },
  );
}
