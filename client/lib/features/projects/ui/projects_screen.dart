import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/app_empty_state.dart';
import 'package:client/core/widgets/app_error_state.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/cubit/projects_list_state.dart';
import 'package:client/features/projects/ui/widgets/create_project_sheet.dart';
import 'package:client/features/projects/ui/widgets/projects_filter_bar.dart';
import 'package:client/features/projects/ui/widgets/projects_grid.dart';
import 'package:client/features/projects/ui/widgets/projects_header.dart';
import 'package:client/features/projects/ui/widgets/projects_skeleton.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/l10n/generated/app_localizations.dart';

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
          foregroundColor: AppColors.pureWhite,
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.newProject),
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
                        const SliverToBoxAdapter(child: ProjectsSkeleton()),
                    loading: () =>
                        const SliverToBoxAdapter(child: ProjectsSkeleton()),
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
                        title: l10n.noProjectsFound,
                        description: l10n.noProjectsDescription,
                        icon: Icons.folder_open_rounded,
                      ),
                    ),
                    loaded: (projects, a, s) {
                      if (projects.isEmpty) {
                        return SliverFillRemaining(
                          child: AppEmptyState(
                            title: l10n.noResults,
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
