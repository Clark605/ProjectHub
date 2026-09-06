import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/utils/responsive_layout.dart';

import 'package:client/features/shell/ui/widgets/shell_presence_indicator.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class ShellTopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onOpenDrawer;
  final VoidCallback? onProfileTap;
  final VoidCallback? onWorkspaceTap;
  final VoidCallback? onSettingsTap;
  final String? activeWorkspaceName;
  final String? activeWorkspaceRole;
  final bool isLoading;

  const ShellTopBar({
    super.key,
    this.onOpenDrawer,
    this.onProfileTap,
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    final hasWorkspace =
        activeWorkspaceName != null && activeWorkspaceName!.trim().isNotEmpty;
    final displayName = hasWorkspace
        ? activeWorkspaceName!
        : (l10n?.createWorkspace ?? 'Create Workspace');
    final isOwner =
        hasWorkspace &&
        activeWorkspaceRole != null &&
        activeWorkspaceRole!.trim().toLowerCase() == 'owner';

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
          // Drawer hamburger on Mobile/Tablet
          if (!isDesktop) ...[
            IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: AppColors.textPrimary,
              ),
              tooltip: 'Navigation Menu',
              onPressed: onOpenDrawer,
            ),
            const SizedBox(width: 8),
          ],

          // Workspace Switcher Trigger
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: isLoading ? null : onWorkspaceTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withValues(
                      alpha: 0.6,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.8),
                    ),
                  ),
                  child: isLoading
                      ? const Skeletonizer(
                          enabled: true,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Bone.circle(size: 8),
                              SizedBox(width: 8),
                              Bone(width: 80, height: 16),
                              SizedBox(width: 6),
                              Bone(width: 14, height: 14),
                            ],
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasWorkspace)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              )
                            else
                              const Icon(
                                Icons.add_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                displayName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasWorkspace &&
                                activeWorkspaceRole != null &&
                                activeWorkspaceRole!.trim().isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  activeWorkspaceRole!,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: 4),
                            Icon(
                              hasWorkspace
                                  ? Icons.keyboard_arrow_down_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              size: hasWorkspace ? 18 : 12,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Live Team Presence Stack
          if (!isMobile) ...[
            const ShellPresenceIndicator(),
            const SizedBox(width: 16),
          ],

          // Owner-only Settings Trigger
          if (isOwner) ...[
            IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              tooltip: 'Workspace Settings',
              onPressed:
                  onSettingsTap ??
                  () => Navigator.of(context).pushNamed(RouteNames.workspaces),
            ),
            const SizedBox(width: 8),
          ],

          // Profile Button
        ],
      ),
    );
  }
}
