import 'package:client/features/dashboard/cubit/activity_stream_state.dart';
import 'package:client/features/dashboard/ui/widgets/activity_stream/activity_empty_state.dart';
import 'package:client/features/dashboard/ui/widgets/activity_stream/activity_filter_empty_state.dart';
import 'package:client/features/dashboard/ui/widgets/activity_stream/activity_stream_list.dart';
import 'package:flutter/material.dart';

class ActivityStreamContent extends StatelessWidget {
  final ActivityStreamState state;
  final VoidCallback onClearFilters;

  const ActivityStreamContent({
    super.key,
    required this.state,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.isRefreshing) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filter zero-state: active filter applied but no activities match
    if (state.filter.hasActiveFilters && state.filteredActivities.isEmpty) {
      return ActivityFilterEmptyState(onClearFilters: onClearFilters);
    }

    // Zero-state: workspace has no activities at all
    if (state.activities.isEmpty) {
      return const ActivityEmptyState();
    }

    return ActivityStreamList(activities: state.filteredActivities);
  }
}
