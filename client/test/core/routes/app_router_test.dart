import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/routes/app_router.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/ui/kanban_screen.dart';
import 'package:client/features/projects/cubit/project_detail_cubit.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/ui/project_detail_screen.dart';

class _MockBuildContext extends Fake implements BuildContext {}

void main() {
  group('AppRouter', () {
    test('projectDetail route accepts int arguments and wraps in BlocProvider', () {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: RouteNames.projectDetail, arguments: 123),
      );
      expect(route, isA<PageRouteBuilder>());
      final pageRoute = route as PageRouteBuilder;
      final widget = pageRoute.pageBuilder(
        _MockBuildContext(),
        const AlwaysStoppedAnimation(1.0),
        const AlwaysStoppedAnimation(1.0),
      );
      expect(widget, isA<BlocProvider<ProjectDetailCubit>>());
      final provider = widget as BlocProvider<ProjectDetailCubit>;
      expect(provider.child, isA<ProjectDetailScreen>());
      expect((provider.child as ProjectDetailScreen).projectId, 123);
    });

    test('projectDetail route accepts string arguments gracefully', () {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: RouteNames.projectDetail, arguments: '456'),
      );
      expect(route, isA<PageRouteBuilder>());
      final pageRoute = route as PageRouteBuilder;
      final widget = pageRoute.pageBuilder(
        _MockBuildContext(),
        const AlwaysStoppedAnimation(1.0),
        const AlwaysStoppedAnimation(1.0),
      );
      expect(widget, isA<BlocProvider<ProjectDetailCubit>>());
      final provider = widget as BlocProvider<ProjectDetailCubit>;
      expect(provider.child, isA<ProjectDetailScreen>());
      expect((provider.child as ProjectDetailScreen).projectId, 456);
    });

    test('projectDetail route handles null or invalid arguments safely', () {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: RouteNames.projectDetail, arguments: null),
      );
      expect(route, isA<PageRouteBuilder>());
      final pageRoute = route as PageRouteBuilder;
      final widget = pageRoute.pageBuilder(
        _MockBuildContext(),
        const AlwaysStoppedAnimation(1.0),
        const AlwaysStoppedAnimation(1.0),
      );
      expect(widget, isA<BlocProvider<ProjectDetailCubit>>());
      final provider = widget as BlocProvider<ProjectDetailCubit>;
      expect(provider.child, isA<ProjectDetailScreen>());
      expect((provider.child as ProjectDetailScreen).projectId, 0);
    });

    test('kanban route accepts int arguments and wraps in BlocProvider', () {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: RouteNames.kanban, arguments: 123),
      );
      expect(route, isA<PageRouteBuilder>());
      final pageRoute = route as PageRouteBuilder;
      final widget = pageRoute.pageBuilder(
        _MockBuildContext(),
        const AlwaysStoppedAnimation(1.0),
        const AlwaysStoppedAnimation(1.0),
      );
      expect(widget, isA<BlocProvider<KanbanCubit>>());
      final provider = widget as BlocProvider<KanbanCubit>;
      expect(provider.child, isA<KanbanScreen>());
      expect((provider.child as KanbanScreen).projectId, 123);
    });

    test('kanban route accepts ProjectDto arguments', () {
      const project = ProjectDto(
        id: 77,
        workspaceId: 1,
        name: 'Alpha Project',
        description: 'Testing',
        status: 'Active',
      );
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: RouteNames.kanban, arguments: project),
      );
      expect(route, isA<PageRouteBuilder>());
      final pageRoute = route as PageRouteBuilder;
      final widget = pageRoute.pageBuilder(
        _MockBuildContext(),
        const AlwaysStoppedAnimation(1.0),
        const AlwaysStoppedAnimation(1.0),
      );
      expect(widget, isA<BlocProvider<KanbanCubit>>());
      final provider = widget as BlocProvider<KanbanCubit>;
      expect(provider.child, isA<KanbanScreen>());
      final kanbanWidget = provider.child as KanbanScreen;
      expect(kanbanWidget.projectId, 77);
      expect(kanbanWidget.initialProject, project);
    });
  });
}
