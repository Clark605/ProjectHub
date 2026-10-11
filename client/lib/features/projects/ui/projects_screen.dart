import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/widgets/app_async_state_wrapper.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/cubit/projects_list_state.dart';
import 'package:client/features/projects/ui/widgets/create_project_sheet.dart';
import 'package:client/features/projects/ui/widgets/projects_filter_bar.dart';
import 'package:client/features/projects/ui/widgets/projects_grid.dart';
import 'package:client/features/projects/ui/widgets/projects_header.dart';
import 'package:client/features/projects/ui/widgets/projects_skeleton.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  int? _lastWorkspaceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final wsState = context.read<WorkspaceContextCubit>().state;
      final activeWs = wsState.whenOrNull(loaded: (_, active) => active);
      if (activeWs != null) {
        _lastWorkspaceId = activeWs.id;
        context.read<ProjectsListCubit>().loadProjects(activeWs.id);
      }
    });
  }

  void _openCreateSheet(BuildContext context) {
    final cubit = context.read<ProjectsListCubit>();
    CreateProjectSheet.show(context, cubit: cubit);
  }

  Future<void> _reloadProjects(BuildContext context) async {
    if (_lastWorkspaceId != null) {
      await context.read<ProjectsListCubit>().loadProjects(
        _lastWorkspaceId!,
        forceRefresh: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<WorkspaceContextCubit, WorkspaceContextState>(
      listener: (context, state) {
        final activeWs = state.whenOrNull(loaded: (_, active) => active);
        if (activeWs != null && activeWs.id != _lastWorkspaceId) {
          _lastWorkspaceId = activeWs.id;
          context.read<ProjectsListCubit>().loadProjects(activeWs.id);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openCreateSheet(context),
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.newProject),
        ),
        body: BlocBuilder<ProjectsListCubit, ProjectsListState>(
          builder: (context, state) {
            final isEmpty = state.maybeWhen(
              empty: (_) => true,
              loaded: (projects, _, _) => projects.isEmpty,
              orElse: () => false,
            );

            return AppAsyncStateWrapper.slivers(
              onRefresh: () => _reloadProjects(context),
              errorMessage: state.whenOrNull(
                error: (failure) => failure.toLocalizedMessage(l10n),
              ),
              isEmpty: isEmpty,
              emptyTitle: state.maybeWhen(
                empty: (_) => l10n.noProjectsFound,
                loaded: (_, _, _) => l10n.noResults,
                orElse: () => null,
              ),
              emptyDescription: state.maybeWhen(
                empty: (_) => l10n.noProjectsDescription,
                orElse: () => null,
              ),
              emptyIcon: state.maybeWhen(
                empty: (_) => Icons.folder_open_rounded,
                loaded: (_, _, _) => Icons.filter_list_off_rounded,
                orElse: () => null,
              ),
              headerSlivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProjectsHeader(
                        onCreatePressed: () => _openCreateSheet(context),
                      ),
                      const ProjectsFilterBar(),
                      AppSpacing.gapH20,
                    ],
                  ),
                ),
              ],
              slivers: state.maybeWhen(
                initial: () => const [
                  SliverToBoxAdapter(child: ProjectsSkeleton()),
                ],
                loading: () => const [
                  SliverToBoxAdapter(child: ProjectsSkeleton()),
                ],
                loaded: (projects, _, _) => [
                  ProjectsGrid(
                    projects: projects,
                    workspaceId: _lastWorkspaceId,
                  ),
                ],
                orElse: () => const [],
              ),
            );
          },
        ),
      ),
    );
  }
}
