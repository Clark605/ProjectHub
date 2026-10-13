import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/widgets/app_async_state_wrapper.dart';
import 'package:client/core/widgets/realtime_status_badge.dart';
import 'package:client/features/dashboard/cubit/activity_stream_cubit.dart';
import 'package:client/features/dashboard/cubit/activity_stream_state.dart';
import 'package:client/features/dashboard/data/activity_repository.dart';
import 'package:client/features/dashboard/ui/widgets/activity_filter_bottom_sheet.dart';
import 'package:client/features/dashboard/ui/widgets/activity_tile.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_presence_avatars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActivityStreamScreen extends StatefulWidget {
  final int workspaceId;
  final ActivityRepository? activityRepository;
  final ProjectRepository? projectRepository;
  final ActivityStreamCubit? cubit;
  final List<ProjectDto>? initialProjects;

  const ActivityStreamScreen({
    super.key,
    required this.workspaceId,
    this.activityRepository,
    this.projectRepository,
    this.cubit,
    this.initialProjects,
  });

  @override
  State<ActivityStreamScreen> createState() => _ActivityStreamScreenState();
}

class _ActivityStreamScreenState extends State<ActivityStreamScreen> {
  late final ActivityStreamCubit _cubit;
  late final bool _isInternalCubit;
  List<ProjectDto> _projects = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialProjects != null) {
      _projects = widget.initialProjects!;
    } else {
      _loadProjects();
    }

    if (widget.cubit != null) {
      _cubit = widget.cubit!;
      _isInternalCubit = false;
      _cubit.loadActivities(widget.workspaceId);
    } else if (widget.activityRepository != null) {
      _cubit = ActivityStreamCubit(widget.activityRepository!);
      _isInternalCubit = true;
      _cubit.loadActivities(widget.workspaceId);
    } else {
      ActivityStreamCubit? ambientCubit;
      try {
        ambientCubit = context.read<ActivityStreamCubit>();
      } on Object catch (_) {
        // Allow fallback to repo resolution
      }
      if (ambientCubit != null) {
        _cubit = ambientCubit;
        _isInternalCubit = false;
      } else {
        ActivityRepository? repo;
        try {
          repo = context.read<ActivityRepository>();
        } on Object catch (_) {
          // Fallback if not in provider tree
        }
        if (repo != null) {
          _cubit = ActivityStreamCubit(repo);
          _isInternalCubit = true;
          _cubit.loadActivities(widget.workspaceId);
        }
      }
    }
  }

  Future<void> _loadProjects() async {
    try {
      ProjectRepository? repo = widget.projectRepository;
      if (repo == null) {
        try {
          repo = context.read<ProjectRepository>();
        } on Object catch (_) {
          // Fallback if not in provider tree
        }
      }
      if (repo != null) {
        final projects = await repo.getProjects(widget.workspaceId);
        if (mounted) {
          setState(() {
            _projects = projects;
          });
        }
      }
    } on Object catch (_) {
      // Non-critical project list for filter dropdown safely falls back to empty
    }
  }

  @override
  void dispose() {
    if (_isInternalCubit) {
      _cubit.close();
    }
    super.dispose();
  }

  void _openFilterSheet(BuildContext context, ActivityStreamState state) {
    ActivityFilterBottomSheet.show(
      context,
      initialFilter: state.filter,
      availableProjects: _projects,
      onApply: (updatedFilter) {
        _cubit.updateFilter(updatedFilter);
      },
    );
  }

  Future<void> _reloadActivities() =>
      _cubit.loadActivities(widget.workspaceId, forceRefresh: true);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return BlocBuilder<ActivityStreamCubit, ActivityStreamState>(
      bloc: _cubit,
      builder: (context, state) {
        final hasActiveFilters = state.filter.hasActiveFilters;

        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Text(
              l10n.teamStream,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                key: const Key('activity_stream_filter_button'),
                icon: Badge(
                  isLabelVisible: hasActiveFilters,
                  backgroundColor: AppColors.primary,
                  smallSize: 8,
                  child: const Icon(Icons.filter_list_rounded),
                ),
                tooltip: l10n.filterAndSort,
                onPressed: () => _openFilterSheet(context, state),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
              WorkspacePresenceAvatars(workspaceId: widget.workspaceId),
              AppSpacing.gapWSm,
              const RealtimeStatusBadge(),
              AppSpacing.gapWLg,
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                _buildQuickFilterBar(theme, l10n, state.filter.category),
                Expanded(
                  child: AppAsyncStateWrapper(
                    wrapInScrollView: false,
                    onRefresh: _reloadActivities,
                    onRetry: _reloadActivities,
                    errorMessage: (!state.isLoading || state.isRefreshing)
                        ? state.failure?.toLocalizedMessage(l10n)
                        : null,
                    child: _buildBody(theme, l10n, state),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickFilterBar(
    ThemeData theme,
    AppLocalizations l10n,
    String currentCategory,
  ) {
    final categories = [
      {'key': 'All', 'label': l10n.allActivities},
      {'key': 'Tasks', 'label': l10n.taskActivities},
      {'key': 'Projects', 'label': l10n.projectActivities},
      {'key': 'Members', 'label': l10n.memberActivities},
    ];

    final isDark = theme.brightness == Brightness.dark;
    final selectedBgColor = isDark
        ? AppColors.primary.withValues(alpha: 0.22)
        : AppColors.primaryContainer.withValues(alpha: 0.18);
    final selectedTextColor = isDark
        ? AppColors.primary
        : AppColors.onElectricVioletContainer;
    final unselectedTextColor = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final selectedBorderColor = isDark
        ? AppColors.primary
        : AppColors.primaryContainer;
    final unselectedBorderColor = isDark
        ? AppColors.border
        : AppColors.lightBorder;

    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.edgeInsetsHLg,
        itemCount: categories.length,
        separatorBuilder: (_, _) => AppSpacing.gapWSm,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = currentCategory == cat['key'];
          return ChoiceChip(
            key: Key('activity_quick_filter_${cat['key']}'),
            label: Text(cat['label']!),
            selected: isSelected,
            selectedColor: selectedBgColor,
            checkmarkColor: selectedTextColor,
            side: BorderSide(
              color: isSelected ? selectedBorderColor : unselectedBorderColor,
              width: isSelected ? 1.5 : 1.0,
            ),
            labelStyle: theme.textTheme.labelMedium?.copyWith(
              color: isSelected ? selectedTextColor : unselectedTextColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            onSelected: (selected) {
              if (selected) {
                _cubit.updateCategory(cat['key']!);
              }
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
          );
        },
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    AppLocalizations l10n,
    ActivityStreamState state,
  ) {
    if (state.isLoading && !state.isRefreshing) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filter zero-state: active filter applied but no activities match
    if (state.filter.hasActiveFilters && state.filteredActivities.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.edgeInsetsAllXxxl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.filter_alt_off_rounded,
                size: AppIconSize.display,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
              AppSpacing.gapHMd,
              Text(
                l10n.noMatchingActivities,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.gapHLg,
              ElevatedButton.icon(
                key: const Key('activity_stream_reset_filters_button'),
                onPressed: _cubit.clearFilters,
                icon: const Icon(Icons.clear_all_rounded),
                label: Text(l10n.clearFilters),
              ),
            ],
          ),
        ),
      );
    }

    // Zero-state: workspace has no activities at all
    if (state.activities.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.edgeInsetsAllXxxl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: AppIconSize.display,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
              AppSpacing.gapHMd,
              Text(
                l10n.noRecentActivity,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          itemCount: state.filteredActivities.length,
          separatorBuilder: (_, _) =>
              Divider(color: theme.colorScheme.outlineVariant, height: 16),
          itemBuilder: (context, index) {
            return ActivityTile(activity: state.filteredActivities[index]);
          },
        ),
      ),
    );
  }
}
