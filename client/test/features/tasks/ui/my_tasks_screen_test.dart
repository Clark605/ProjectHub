import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/features/tasks/cubit/my_tasks_cubit.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/ui/my_tasks_screen.dart';
import 'package:client/l10n/generated/app_localizations.dart';

import 'package:mocktail/mocktail.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';

import '../../../helpers/mock_repositories.dart';

class MockWorkspaceContextCubit extends Mock implements WorkspaceContextCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createWidgetUnderTest(
    MyTasksCubit cubit, [
    WorkspaceContextCubit? wsCubit,
  ]) {
    final workspaceCubit = wsCubit ?? MockWorkspaceContextCubit();
    if (wsCubit == null) {
      when(() => workspaceCubit.state).thenReturn(
        const WorkspaceContextState.initial(),
      );
      when(() => workspaceCubit.stream).thenAnswer((_) => const Stream.empty());
    }
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<WorkspaceContextCubit>.value(value: workspaceCubit),
            BlocProvider<MyTasksCubit>.value(value: cubit),
          ],
          child: const MyTasksScreen(),
        ),
      ),
    );
  }

  testWidgets(
    'MyTasksScreen renders header and empty state when no tasks exist',
    (tester) async {
      final repo = createMockTaskRepository(tasks: []);
      final cubit = MyTasksCubit(repo);

      await tester.pumpWidget(createWidgetUnderTest(cubit));
      await cubit.loadMyTasks(10);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('My Tasks'), findsOneWidget);
      expect(
        find.text('Personal tasks and assigned deliverables.'),
        findsOneWidget,
      );
      expect(find.text('No Assigned Tasks'), findsOneWidget);
    },
  );

  testWidgets('MyTasksScreen renders urgency sections when tasks are loaded', (
    tester,
  ) async {
    final repo = createMockTaskRepository(
      tasks: const [
        TaskDto(
          id: 1,
          projectId: 1,
          projectName: 'Mobile App',
          title: 'Fix crash on launch',
          priority: 'Urgent',
          status: 'Todo',
        ),
        TaskDto(
          id: 2,
          projectId: 1,
          projectName: 'Backend API',
          title: 'Implement token rotation',
          priority: 'High',
          status: 'InProgress',
        ),
      ],
    );
    final cubit = MyTasksCubit(repo);

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await cubit.loadMyTasks(10);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Overdue & Urgent'), findsOneWidget);
    expect(find.text('Fix crash on launch'), findsOneWidget);
    expect(find.text('In Progress'), findsNWidgets(2));
    expect(find.text('Implement token rotation'), findsOneWidget);
  });
}
