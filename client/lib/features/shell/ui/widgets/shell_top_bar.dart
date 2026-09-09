import 'package:flutter/material.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/utils/responsive_layout.dart';
import 'package:client/features/shell/ui/widgets/shell_presence_indicator.dart';
import 'package:client/features/shell/ui/widgets/workspace_switcher_pill.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class ShellTopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onOpenDrawer;
  final VoidCallback? onWorkspaceTap;
  final VoidCallback? onSettingsTap;
  final String? activeWorkspaceName;
  final String? activeWorkspaceRole;
  final bool isLoading;

  const ShellTopBar({
    super.key,
    this.onOpenDrawer,
    this.onWorkspaceTap,
    this.onSettingsTap,
    this.activeWorkspaceName,
    this.activeWorkspaceRole,
    this.isLoading = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    final hasWorkspace =
        activeWorkspaceName != null && activeWorkspaceName!.trim().isNotEmpty;
    final isOwner =
        hasWorkspace &&
        activeWorkspaceRole != null &&
        activeWorkspaceRole!.trim().toLowerCase() == 'owner';

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (!isDesktop) ...[
            IconButton(
              icon: Icon(
                Icons.menu_rounded,
                color: theme.colorScheme.onSurface,
              ),
              tooltip: l10n?.navigationMenu ?? 'Navigation Menu',
              onPressed: onOpenDrawer,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: WorkspaceSwitcherPill(
                activeWorkspaceName: activeWorkspaceName,
                activeWorkspaceRole: activeWorkspaceRole,
                isLoading: isLoading,
                onWorkspaceTap: onWorkspaceTap,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (!isMobile) ...[
            const ShellPresenceIndicator(),
            const SizedBox(width: 16),
          ],
          if (isOwner) ...[
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              tooltip: l10n?.workspaceSettings ?? 'Workspace Settings',
              onPressed:
                  onSettingsTap ??
                  () => Navigator.of(context).pushNamed(RouteNames.workspaces),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
