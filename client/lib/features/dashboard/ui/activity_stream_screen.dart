import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/dashboard/cubit/activity_stream_cubit.dart';
import 'package:client/features/dashboard/cubit/activity_stream_state.dart';
import 'package:client/features/dashboard/data/activity_repository.dart';
import 'package:client/features/dashboard/ui/widgets/activity_filter_bottom_sheet.dart';
import 'package:client/features/dashboard/ui/widgets/activity_tile.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_presence_avatars.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class ActivityStreamScreen extends StatefulWidget {
  final int workspaceId;
  final ActivityRepository? activityRepository;
  final ActivityStreamCubit? cubit;

  const ActivityStreamScreen({
    super.key,
    required this.workspaceId,
    this.activityRepository,
    this.cubit,
  });

  @override
  State<ActivityStreamScreen> createState() => _ActivityStreamScreenState();
}

class _ActivityStreamScreenState extends State<ActivityStreamScreen> {
  late final ActivityStreamCubit _cubit;
  late final bool _isInternalCubit;

  @override
  void initState() {
    super.initState();
    if (widget.cubit != null) {
      _cubit = widget.cubit!;
      _isInternalCubit = false;
      _cubit.loadActivities(widget.workspaceId);
    } else {
      final repo = widget.activityRepository ?? getIt<ActivityRepository>();
      _cubit = ActivityStreamCubit(repo);
      _isInternalCubit = true;
      _cubit.loadActivities(widget.workspaceId);
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
            title: Text(
              l10n?.teamStream ?? 'Team Presence & Stream',
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
                tooltip: l10n?.filterAndSort ?? 'Filter & Sort',
                onPressed: () => _openFilterSheet(context, state),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
              Center(
                child:
                    WorkspacePresenceAvatars(workspaceId: widget.workspaceId),
              ),
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
    AppLocalizations? l10n,
    String currentCategory,
  ) {
    final categories = [
      {'key': 'All', 'label': l10n?.allActivities ?? 'All'},
      {'key': 'Tasks', 'label': l10n?.taskActivities ?? 'Tasks'},
      {'key': 'Projects', 'label': l10n?.projectActivities ?? 'Projects'},
      {'key': 'Members', 'label': l10n?.memberActivities ?? 'Members'},
    ];

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
    AppLocalizations? l10n,
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
                label: Text(l10n?.retry ?? 'Retry'),
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
                l10n?.noMatchingActivities ?? 'No activities match your filters',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                key: const Key('activity_stream_reset_filters_button'),
                onPressed: _cubit.clearFilters,
                icon: const Icon(Icons.clear_all_rounded),
                label: Text(l10n?.clearFilters ?? 'Reset Filters'),
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
                l10n?.noRecentActivity ?? 'No recent activity yet',
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
