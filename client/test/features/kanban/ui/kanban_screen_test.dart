import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/routes/route_names.dart';
import 'package:client/features/kanban/ui/kanban_screen.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

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
  }) {
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
      home: KanbanScreen(projectId: projectId, initialProject: initialProject),
    );
  }

  testWidgets('KanbanScreen renders project title and placeholder content', (
    tester,
  ) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        projectId: testProject.id,
        initialProject: testProject,
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify title and subtitle
    expect(find.text('Apollo Project'), findsOneWidget);
    expect(find.text('Kanban Board'), findsOneWidget);
    expect(find.text('Kanban Board (Placeholder)'), findsOneWidget);
    expect(
      find.text('Sprint & Kanban Orchestration is coming soon.'),
      findsOneWidget,
    );

    // Verify presence of settings icon button
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

      // Tap settings icon in AppBar
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Verify navigation to settings
      expect(find.text('Settings for project 42'), findsOneWidget);
    },
  );
}
