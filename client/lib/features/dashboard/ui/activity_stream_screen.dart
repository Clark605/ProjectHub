import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/realtime_status_badge.dart';
import 'package:client/features/dashboard/cubit/activity_stream_cubit.dart';
import 'package:client/features/dashboard/cubit/activity_stream_state.dart';
import 'package:client/features/dashboard/data/activity_repository.dart';
import 'package:client/features/dashboard/ui/widgets/activity_filter_bottom_sheet.dart';
import 'package:client/features/dashboard/ui/widgets/activity_tile.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_presence_avatars.dart';
import 'package:client/l10n/generated/app_localizations.dart';

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
      } catch (_) {
        // Allow fallback to repo resolution
      }
      if (ambientCubit != null) {
        _cubit = ambientCubit;
        _isInternalCubit = false;
      } else {
        ActivityRepository? repo;
        try {
          repo = context.read<ActivityRepository>();
        } catch (_) {
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
        } catch (_) {
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
    } catch (_) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
              const SizedBox(width: 8),
              const RealtimeStatusBadge(),
              const SizedBox(width: 16),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                _buildQuickFilterBar(theme, l10n, state.filter.category),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _cubit.loadActivities(
                      widget.workspaceId,
                      forceRefresh: true,
                    ),
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
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
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
            labelStyle: TextStyle(
              color: isSelected ? selectedTextColor : unselectedTextColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
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

    if (state.errorMessage != null) {
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
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _cubit.loadActivities(
                  widget.workspaceId,
                  forceRefresh: true,
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    // Filter zero-state: active filter applied but no activities match
    if (state.filter.hasActiveFilters && state.filteredActivities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.filter_alt_off_rounded,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.noMatchingActivities,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
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
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
              const SizedBox(height: 12),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
