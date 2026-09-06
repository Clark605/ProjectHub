import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/utils/responsive_layout.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/cubit/projects_list_state.dart';
import 'package:client/features/projects/ui/widgets/create_project_sheet.dart';
import 'package:client/features/projects/ui/widgets/project_card.dart';
import 'package:client/features/projects/ui/widgets/projects_skeleton.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/data/project_repository.dart';
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

    if (getIt.isRegistered<ProjectsListCubit>()) {
      return BlocProvider<ProjectsListCubit>(
        create: (_) => getIt<ProjectsListCubit>(),
        child: const _ProjectsView(),
      );
    }

    return BlocProvider<ProjectsListCubit>(
      create: (_) => getIt.isRegistered<ProjectRepository>()
          ? ProjectsListCubit(getIt<ProjectRepository>())
          : ProjectsListCubit(_NoOpProjectRepository()),
      child: const _ProjectsView(),
    );
  }
}

class _NoOpProjectRepository implements ProjectRepository {
  @override
  Future<List<ProjectDto>> getProjects(
    int workspaceId, {
    String? status,
    bool forceRefresh = false,
  }) async => [];

  @override
  Future<ProjectDto> getProject(int id, {bool forceRefresh = false}) async =>
      ProjectDto(id: id, workspaceId: 0, name: '');

  @override
  Future<ProjectDto> createProject(
    int workspaceId,
    CreateProjectRequest request,
  ) async => ProjectDto(id: 0, workspaceId: workspaceId, name: request.name);

  @override
  Future<ProjectDto> updateProject(
    int id,
    UpdateProjectRequest request,
  ) async => ProjectDto(id: id, workspaceId: 0, name: request.name);

  @override
  Future<void> deleteProject(int id) async {}

  @override
  void clearCache([int? workspaceId]) {}

  @override
  bool hasCachedProjects(int workspaceId) => false;

  @override
  bool hasCachedProject(int id) => false;
}

class _ProjectsView extends StatefulWidget {
  const _ProjectsView();

  @override
  State<_ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<_ProjectsView> {
  int? _lastWorkspaceId;

  static const List<String> _filters = [
    'All',
    'Planning',
    'Active',
    'Completed',
    'Archived',
  ];

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

  String _getFilterLabel(BuildContext context, String filter) {
    final l10n = AppLocalizations.of(context);
    switch (filter.toLowerCase()) {
      case 'all':
        return l10n?.statusAll ?? 'All';
      case 'planning':
        return l10n?.statusPlanning ?? 'Planning';
      case 'active':
        return l10n?.statusActive ?? 'Active';
      case 'completed':
        return l10n?.statusCompleted ?? 'Completed';
      case 'archived':
        return l10n?.statusArchived ?? 'Archived';
      default:
        return filter;
    }
  }

  void _openCreateSheet(BuildContext context) {
    final cubit = context.read<ProjectsListCubit>();
    CreateProjectSheet.show(context, cubit: cubit);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final columns = isDesktop
        ? 3
        : (ResponsiveLayout.isTablet(context) ? 2 : 1);

    return MultiBlocListener(
      listeners: [
        BlocListener<WorkspaceContextCubit, WorkspaceContextState>(
          listener: (context, state) {
            final activeWs = state.whenOrNull(loaded: (_, active) => active);
            if (activeWs != null && activeWs.id != _lastWorkspaceId) {
              _lastWorkspaceId = activeWs.id;
              context.read<ProjectsListCubit>().loadProjects(activeWs.id);
            }
          },
        ),
      ],
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
                  // ── Header ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n?.projectsTitle ?? 'Projects',
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.5,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n?.projectsSubtitle ??
                                          'Manage workspace projects and track deliverables.',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: isDark
                                                ? AppColors.textSecondary
                                                : AppColors.lightTextSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isDesktop) ...[
                                const SizedBox(width: 16),
                                AppButton(
                                  label:
                                      l10n?.createProject ?? 'Create Project',
                                  icon: Icons.add_rounded,
                                  isExpanded: false,
                                  onPressed: () => _openCreateSheet(context),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 20),
                          // ── Status Filter Chips ──
                          _buildFilterChips(context, state),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // ── Body Content ──
                  state.when(
                    initial: () =>
                        const SliverFillRemaining(child: ProjectsSkeleton()),
                    loading: () =>
                        const SliverFillRemaining(child: ProjectsSkeleton()),
                    error: (message) => SliverFillRemaining(
                      child: _buildError(context, message),
                    ),
                    empty: (filter) =>
                        SliverFillRemaining(child: _buildEmptyState(context)),
                    loaded: (projects, allProjects, selectedFilter) {
                      if (projects.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.filter_list_off_rounded,
                                    size: 48,
                                    color: AppColors.textTertiary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n?.noResults ?? 'No results found',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 175,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final project = projects[index];
                            return ProjectCard(
                              project: project,
                              onTap: () async {
                                final result = await Navigator.of(context)
                                    .pushNamed(
                                      RouteNames.kanban,
                                      arguments: project,
                                    );
                                if (result == true &&
                                    _lastWorkspaceId != null &&
                                    context.mounted) {
                                  context
                                      .read<ProjectsListCubit>()
                                      .loadProjects(
                                        _lastWorkspaceId!,
                                        forceRefresh: true,
                                      );
                                }
                              },
                            );
                          }, childCount: projects.length),
                        ),
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

  Widget _buildFilterChips(BuildContext context, ProjectsListState state) {
    final currentFilter = state.maybeWhen(
      loaded: (projects, allProjects, selected) => selected,
      empty: (selected) => selected,
      orElse: () => 'All',
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected =
              currentFilter.toLowerCase() == filter.toLowerCase();

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_getFilterLabel(context, filter)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  context.read<ProjectsListCubit>().filterByStatus(filter);
                }
              },
              selectedColor: AppColors.electricVioletContainer,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
              backgroundColor: AppColors.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.electricVioletContainer
                      : AppColors.border.withValues(alpha: 0.6),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceContainerLow.withValues(alpha: 0.8)
              : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppColors.border.withValues(alpha: 0.6)
                : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.electricViolet.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.electricViolet.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.folder_special_rounded,
                size: 32,
                color: AppColors.electricViolet,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.noProjectsFound ?? 'No projects found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.noProjectsDescription ??
                  'Get started by creating your first project in this workspace.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: l10n?.createProject ?? 'Create Project',
              icon: Icons.add_rounded,
              isExpanded: false,
              onPressed: () => _openCreateSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_lastWorkspaceId != null) {
                  context.read<ProjectsListCubit>().loadProjects(
                    _lastWorkspaceId!,
                    forceRefresh: true,
                  );
                }
              },
              child: Text(l10n?.retry ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
