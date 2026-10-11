import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:client/core/theme/workspace_accent.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class WorkspaceSwitcherPill extends StatelessWidget {
  final String? activeWorkspaceName;
  final String? activeWorkspaceRole;
  final String? activeWorkspaceAccent;
  final bool isLoading;
  final VoidCallback? onWorkspaceTap;

  const WorkspaceSwitcherPill({
    super.key,
    this.activeWorkspaceName,
    this.activeWorkspaceRole,
    this.activeWorkspaceAccent,
    this.isLoading = false,
    this.onWorkspaceTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final hasWorkspace =
        activeWorkspaceName != null && activeWorkspaceName!.trim().isNotEmpty;
    final displayName = hasWorkspace
        ? activeWorkspaceName!
        : (l10n.createWorkspace);

    final accent = WorkspaceAccent.fromId(activeWorkspaceAccent);
    final accentColor = accent.resolvedColor(theme.brightness);

    return InkWell(
      onTap: isLoading ? null : onWorkspaceTap,
      borderRadius: AppRadius.r10,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s10,
          vertical: AppSpacing.s6,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
          borderRadius: AppRadius.r10,
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.8),
          ),
        ),
        child: isLoading
            ? const Skeletonizer(
                enabled: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Bone.circle(size: 8),
                    AppSpacing.gapW8,
                    Bone(width: 80, height: 16),
                    AppSpacing.gapW6,
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor,
                      ),
                    )
                  else
                    Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  AppSpacing.gapW8,
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
                    AppSpacing.gapW6,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s6,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: AppRadius.r4,
                      ),
                      child: Text(
                        activeWorkspaceRole!,
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  AppSpacing.gapW4,
                  Icon(
                    hasWorkspace
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: hasWorkspace ? 18 : 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
      ),
    );
  }
}
