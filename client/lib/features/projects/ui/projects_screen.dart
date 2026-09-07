import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/app_empty_state.dart';
import 'package:client/core/widgets/app_error_state.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/cubit/projects_list_state.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/projects/ui/widgets/create_project_sheet.dart';
import 'package:client/features/projects/ui/widgets/projects_filter_bar.dart';
import 'package:client/features/projects/ui/widgets/projects_grid.dart';
import 'package:client/features/projects/ui/widgets/projects_header.dart';
import 'package:client/features/projects/ui/widgets/projects_skeleton.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class ProjectsScreen extends StatelessWidget {
  final ProjectsListCubit? cubit;

  const ProjectsScreen({super.key, this.cubit});

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider<ProjectsListCubit>.value(
        value: cubit!,
        child: const _ProjectsView(),
      );
    }

    try {
      final ambientCubit = context.read<ProjectsListCubit>();
      return BlocProvider<ProjectsListCubit>.value(
        value: ambientCubit,
        child: const _ProjectsView(),
      );
    } catch (_) {
      return BlocProvider<ProjectsListCubit>(
        create: (_) => getIt.isRegistered<ProjectsListCubit>()
            ? getIt<ProjectsListCubit>()
            : ProjectsListCubit(getIt<ProjectRepository>()),
        child: const _ProjectsView(),
      );
    }
  }
}

class _ProjectsView extends StatefulWidget {
  const _ProjectsView();

  @override
  State<_ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<_ProjectsView> {
  int? _lastWorkspaceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkWorkspaceReload();
    });
  }

  void _checkWorkspaceReload() {
    try {
      final wsState = context.read<WorkspaceContextCubit>().state;
      final activeWs = wsState.whenOrNull(loaded: (_, active) => active);

      if (activeWs != null && activeWs.id != _lastWorkspaceId) {
        _lastWorkspaceId = activeWs.id;
        context.read<ProjectsListCubit>().loadProjects(activeWs.id);
      }
    } catch (_) {}
  }

  void _openCreateSheet(BuildContext context) {
    final cubit = context.read<ProjectsListCubit>();
    CreateProjectSheet.show(context, cubit: cubit);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
          backgroundColor: AppColors.electricVioletContainer,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n?.newProject ?? 'New Project'),
        ),
        body: BlocBuilder<ProjectsListCubit, ProjectsListState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                if (_lastWorkspaceId != null) {
                  await context.read<ProjectsListCubit>().loadProjects(
                    _lastWorkspaceId!,
                    forceRefresh: true,
                  );
                }
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProjectsHeader(
                          onCreatePressed: () => _openCreateSheet(context),
                        ),
                        const ProjectsFilterBar(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  state.when(
                    initial: () =>
                        const SliverFillRemaining(child: ProjectsSkeleton()),
                    loading: () =>
                        const SliverFillRemaining(child: ProjectsSkeleton()),
                    error: (message) => SliverFillRemaining(
                      child: AppErrorState(
                        errorMessage: message,
                        onRetry: () {
                          if (_lastWorkspaceId != null) {
                            context.read<ProjectsListCubit>().loadProjects(
                              _lastWorkspaceId!,
                              forceRefresh: true,
                            );
                          }
                        },
                      ),
                    ),
                    empty: (filter) => SliverFillRemaining(
                      child: AppEmptyState(
                        title: l10n?.noProjectsFound ?? 'No projects found',
                        description:
                            l10n?.noProjectsDescription ??
                            'Get started by creating your first project in this workspace.',
                        icon: Icons.folder_special_rounded,
                        ctaText: l10n?.createProject ?? 'Create Project',
                        onCtaPressed: () => _openCreateSheet(context),
                      ),
                    ),
                    loaded: (projects, a, s) {
                      if (projects.isEmpty) {
                        return SliverFillRemaining(
                          child: AppEmptyState(
                            title: l10n?.noResults ?? 'No results found',
                            description: '',
                            icon: Icons.filter_list_off_rounded,
                          ),
                        );
                      }
                      return ProjectsGrid(
                        projects: projects,
                        workspaceId: _lastWorkspaceId,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
