import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

import 'package:client/core/theme/workspace_accent.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class WorkspaceCard extends StatelessWidget {
  final WorkspaceDto workspace;
  final bool isActive;
  final VoidCallback onTap;

  const WorkspaceCard({
    super.key,
    required this.workspace,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final role = workspace.membership?.role ?? l10n.roleMember;
    final isOwner = role.toLowerCase() == 'owner';

    final accent = WorkspaceAccent.fromId(workspace.accentColor);
    final accentColor = accent.resolvedColor(theme.brightness);
    final onAccent = accent.resolvedOnAccent(theme.brightness);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.r12,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? accentColor.withValues(alpha: 0.1)
                : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
            borderRadius: AppRadius.r12,
            border: Border.all(
              color: isActive
                  ? accentColor.withValues(alpha: 0.6)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              width: isActive ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // Active / Accent Indicator Circle
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? accentColor : Colors.transparent,
                  border: Border.all(
                    color: isActive
                        ? accentColor
                        : theme.colorScheme.outlineVariant,
                    width: 1.5,
                  ),
                ),
                child: isActive
                    ? Icon(
                        Icons.check_rounded,
                        size: AppIconSize.sm,
                        color: onAccent,
                      )
                    : Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor,
                          ),
                        ),
                      ),
              ),
              AppSpacing.gapWMd,

              // Title & Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      workspace.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (workspace.description.isNotEmpty) ...[
                      AppSpacing.gapHXxs,
                      Text(
                        workspace.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              AppSpacing.gapWSm,

              // Role Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isOwner
                      ? theme.colorScheme.primary.withValues(alpha: 0.15)
                      : theme.colorScheme.secondary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.r6,
                  border: Border.all(
                    color: isOwner
                        ? theme.colorScheme.primary.withValues(alpha: 0.3)
                        : theme.colorScheme.secondary.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  isOwner ? l10n.roleOwner : l10n.roleMember,
                  style: TextStyle(
                    color: isOwner
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
