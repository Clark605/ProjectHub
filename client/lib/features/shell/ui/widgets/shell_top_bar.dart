import 'package:flutter/material.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/utils/responsive_layout.dart';
import 'package:client/features/shell/ui/widgets/shell_presence_indicator.dart';
import 'package:client/features/shell/ui/widgets/workspace_switcher_pill.dart';

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

    final hasWorkspace = activeWorkspaceName != null && activeWorkspaceName!.trim().isNotEmpty;
    final isOwner = hasWorkspace && activeWorkspaceRole != null && activeWorkspaceRole!.trim().toLowerCase() == 'owner';

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (!isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
              tooltip: 'Navigation Menu',
              onPressed: onOpenDrawer,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
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
              icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 20),
              tooltip: 'Workspace Settings',
              onPressed: onSettingsTap ?? () => Navigator.of(context).pushNamed(RouteNames.workspaces),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
