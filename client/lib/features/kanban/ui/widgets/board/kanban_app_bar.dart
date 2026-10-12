import 'package:flutter/material.dart';

import 'package:client/core/theme/workspace_accent.dart';
import 'package:client/core/widgets/realtime_status_badge.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_presence_avatars.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class KanbanAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String projectName;
  final String? wsAccent;
  final int? workspaceId;
  final VoidCallback onSettings;

  const KanbanAppBar({
    super.key,
    required this.projectName,
    this.wsAccent,
    this.workspaceId,
    required this.onSettings,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final accentColor = WorkspaceAccent.resolve(wsAccent, theme.brightness);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      bottom: accentColor != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(2),
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor,
                      accentColor.withValues(alpha: 0.6),
                      accentColor.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            )
          : null,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            projectName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(l10n.kanbanBoard, style: theme.textTheme.bodySmall),
        ],
      ),
      actions: [
        const Center(child: RealtimeStatusBadge()),
        AppSpacing.gapWXs,
        if (workspaceId != null) ...[
          WorkspacePresenceAvatars(workspaceId: workspaceId!),
          AppSpacing.gapWXs,
        ],
        IconButton(
          icon: Icon(
            Icons.settings_outlined,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          tooltip: l10n.projectDetails,
          onPressed: onSettings,
        ),
        AppSpacing.gapWSm,
      ],
    );
  }
}
