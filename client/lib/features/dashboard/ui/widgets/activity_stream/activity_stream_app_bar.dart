import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/widgets/realtime_status_badge.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_presence_avatars.dart';
import 'package:flutter/material.dart';

class ActivityStreamAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int workspaceId;
  final bool hasActiveFilters;
  final VoidCallback onFilterPressed;

  const ActivityStreamAppBar({
    super.key,
    required this.workspaceId,
    required this.hasActiveFilters,
    required this.onFilterPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return AppBar(
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
          onPressed: onFilterPressed,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
        WorkspacePresenceAvatars(workspaceId: workspaceId),
        AppSpacing.gapWSm,
        const RealtimeStatusBadge(),
        AppSpacing.gapWLg,
      ],
    );
  }
}
