import 'package:client/core/theme/app_spacing.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/dashboard/ui/widgets/activity_stream/activity_tile.dart';
import 'package:flutter/material.dart';

class ActivityStreamList extends StatelessWidget {
  final List<ActivityEventDto> activities;

  const ActivityStreamList({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          itemCount: activities.length,
          separatorBuilder: (_, _) =>
              Divider(color: theme.colorScheme.outlineVariant, height: 16),
          itemBuilder: (context, index) {
            return ActivityTile(activity: activities[index]);
          },
        ),
      ),
    );
  }
}
