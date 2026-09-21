import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/workspace_accent.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_presence_avatars.dart';
import 'package:client/l10n/generated/app_localizations.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final accentColor = wsAccent != null && wsAccent!.trim().isNotEmpty
        ? WorkspaceAccent.fromId(wsAccent!).resolvedColor(theme.brightness)
        : null;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
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
        children: [
          Text(
            projectName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            l10n?.kanbanBoard ?? 'Kanban Board',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.lightTextSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        if (workspaceId != null) ...[
          Center(child: WorkspacePresenceAvatars(workspaceId: workspaceId!)),
          const SizedBox(width: 4),
        ],
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: l10n?.projectDetails ?? 'Project Settings',
          onPressed: onSettings,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
