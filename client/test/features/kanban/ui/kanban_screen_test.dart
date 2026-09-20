import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/routes/route_names.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/ui/kanban_screen.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';
import 'fakes/kanban_test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testProject = ProjectDto(
    id: 42,
    workspaceId: 1,
    name: 'Apollo Project',
    description: 'Mission to space',
    status: 'Active',
  );

  Widget createWidgetUnderTest({
    required int projectId,
    ProjectDto? initialProject,
    KanbanCubit? cubit,
  }) {
    final effectiveCubit =
        cubit ??
        KanbanCubit(
          TestTaskRepository([]),
          TestProjectRepository(initialProject ?? testProject),
        );

    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        RouteNames.projectDetail: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return Scaffold(
            body: Center(child: Text('Settings for project $args')),
          );
        },
      },
      home: KanbanScreen(
        projectId: projectId,
        initialProject: initialProject,
        cubit: effectiveCubit,
      ),
    );
  }

  testWidgets('KanbanScreen renders project title and board content', (
    tester,
  ) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        projectId: testProject.id,
        initialProject: testProject,
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Apollo Project'), findsOneWidget);
    expect(find.text('Kanban Board'), findsOneWidget);
    expect(find.text('Board is Empty'), findsOneWidget);
    expect(find.text('New Task'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets(
    'KanbanScreen settings icon button opens project details screen',
    (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          projectId: testProject.id,
          initialProject: testProject,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Settings for project 42'), findsOneWidget);
    },
  );

  testWidgets(
    'KanbanScreen renders responsive PageView on mobile viewport (390x844)',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeTaskRepo = TestTaskRepository([
        const TaskDto(
          id: 101,
          projectId: 42,
          title: 'Mobile Architecture Task',
          status: 'Backlog',
          priority: 'High',
        ),
      ]);
      final fakeProjectRepo = TestProjectRepository(testProject);
      final cubit = KanbanCubit(fakeTaskRepo, fakeProjectRepo);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: KanbanScreen(
            projectId: testProject.id,
            initialProject: testProject,
            cubit: cubit,
          ),
        ),
      );
      await cubit.loadTasks(testProject.id);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PageView), findsOneWidget);
      expect(find.text('Backlog (1)'), findsOneWidget);
      expect(find.text('Mobile Architecture Task'), findsOneWidget);
    },
  );

  testWidgets(
    'swiping PageView on mobile auto-scrolls filter chips and reveals off-screen chips',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeTaskRepo = TestTaskRepository([
        const TaskDto(
          id: 101,
          projectId: 42,
          title: 'Sync Chip Task',
          status: 'Backlog',
          priority: 'High',
        ),
      ]);
      final fakeProjectRepo = TestProjectRepository(testProject);
      final cubit = KanbanCubit(fakeTaskRepo, fakeProjectRepo);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: KanbanScreen(
            projectId: testProject.id,
            initialProject: testProject,
            cubit: cubit,
          ),
        ),
      );
      await cubit.loadTasks(testProject.id);
      await tester.pump(const Duration(milliseconds: 300));

      // Swipe PageView to column 3 (In Review)
      await tester.drag(find.byType(PageView), const Offset(-360, 0));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.drag(find.byType(PageView), const Offset(-360, 0));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.drag(find.byType(PageView), const Offset(-360, 0));
      await tester.pump(const Duration(milliseconds: 400));

      // "In Review (0)" chip should now be scrolled into view
      expect(find.text('In Review (0)'), findsOneWidget);
    },
  );

  testWidgets(
    'KanbanScreen renders horizontal multi-column board on desktop viewport (1200x800)',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeTaskRepo = TestTaskRepository([
        const TaskDto(
          id: 101,
          projectId: 42,
          title: 'Desktop Multi-column Task',
          status: 'Backlog',
          priority: 'Medium',
        ),
      ]);
      final fakeProjectRepo = TestProjectRepository(testProject);
      final cubit = KanbanCubit(fakeTaskRepo, fakeProjectRepo);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: KanbanScreen(
            projectId: testProject.id,
            initialProject: testProject,
            cubit: cubit,
          ),
        ),
      );
      await cubit.loadTasks(testProject.id);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PageView), findsNothing);
      expect(find.text('Desktop Multi-column Task'), findsOneWidget);
      expect(find.text('Backlog'), findsAtLeast(1));
      expect(find.text('To Do'), findsAtLeast(1));
    },
  );
}
