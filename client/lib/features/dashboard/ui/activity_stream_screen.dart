import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/widgets/app_async_state_wrapper.dart';
import 'package:client/features/dashboard/cubit/activity_stream_cubit.dart';
import 'package:client/features/dashboard/cubit/activity_stream_state.dart';
import 'package:client/features/dashboard/ui/widgets/activity_stream/activity_filter_bottom_sheet.dart';
import 'package:client/features/dashboard/ui/widgets/activity_stream/activity_quick_filter_bar.dart';
import 'package:client/features/dashboard/ui/widgets/activity_stream/activity_stream_app_bar.dart';
import 'package:client/features/dashboard/ui/widgets/activity_stream/activity_stream_content.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActivityStreamScreen extends StatefulWidget {
  final int workspaceId;
  final ActivityStreamCubit? cubit;
  final List<ProjectDto>? initialProjects;

  const ActivityStreamScreen({
    super.key,
    required this.workspaceId,
    this.cubit,
    this.initialProjects,
  });

  @override
  State<ActivityStreamScreen> createState() => _ActivityStreamScreenState();
}

class _ActivityStreamScreenState extends State<ActivityStreamScreen> {
  late final ActivityStreamCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? context.read<ActivityStreamCubit>();
    if (widget.initialProjects != null && widget.initialProjects!.isNotEmpty) {
      _cubit.setAvailableProjects(widget.initialProjects!);
    }
    _cubit.loadActivities(widget.workspaceId);
  }

  void _openFilterSheet(BuildContext context, ActivityStreamState state) {
    final projects = state.availableProjects.isNotEmpty
        ? state.availableProjects
        : (widget.initialProjects ?? const []);

    ActivityFilterBottomSheet.show(
      context,
      initialFilter: state.filter,
      availableProjects: projects,
      onApply: (updatedFilter) {
        _cubit.updateFilter(updatedFilter);
      },
    );
  }

  Future<void> _reloadActivities() =>
      _cubit.loadActivities(widget.workspaceId, forceRefresh: true);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<ActivityStreamCubit, ActivityStreamState>(
      bloc: _cubit,
      builder: (context, state) {
        return Scaffold(
          appBar: ActivityStreamAppBar(
            workspaceId: widget.workspaceId,
            hasActiveFilters: state.filter.hasActiveFilters,
            onFilterPressed: () => _openFilterSheet(context, state),
          ),
          body: SafeArea(
            child: Column(
              children: [
                ActivityQuickFilterBar(
                  currentCategory: state.filter.category,
                  onCategorySelected: _cubit.updateCategory,
                ),
                Expanded(
                  child: AppAsyncStateWrapper(
                    wrapInScrollView: false,
                    onRefresh: _reloadActivities,
                    onRetry: _reloadActivities,
                    errorMessage: (!state.isLoading || state.isRefreshing)
                        ? state.failure?.toLocalizedMessage(l10n)
                        : null,
                    child: ActivityStreamContent(
                      state: state,
                      onClearFilters: _cubit.clearFilters,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

