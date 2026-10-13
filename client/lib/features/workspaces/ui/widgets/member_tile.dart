import 'package:client/core/dialog/app_confirm_dialog.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_avatar_size.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/widgets/app_avatar.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_cubit.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MemberTile extends StatelessWidget {
  final MemberDto member;

  const MemberTile({super.key, required this.member});

  Future<void> _confirmRemoval(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<WorkspaceSettingsCubit>();

    final confirm = await showAppConfirmDialog(
      context: context,
      title: l10n.removeMemberTitle,
      message: l10n.confirmRemoveMember(
        member.name.isNotEmpty ? member.name : member.email,
      ),
      confirmLabel: l10n.removeMember,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );

    if (confirm == true) {
      await cubit.removeMember(member.userId);
    }
  }

  Future<void> _confirmRoleChange(
    BuildContext context,
    String targetRole,
  ) async {
    final l10n = context.l10n;
    final cubit = context.read<WorkspaceSettingsCubit>();

    final confirm = await showAppConfirmDialog(
      context: context,
      title: l10n.confirmChangeRoleTitle,
      message: l10n.confirmChangeRole(
        member.name.isNotEmpty ? member.name : member.email,
        targetRole == 'Owner' ? l10n.roleOwner : l10n.roleMember,
      ),
      confirmLabel: l10n.save,
      cancelLabel: l10n.cancel,
    );

    if (confirm == true) {
      await cubit.updateMemberRole(member.userId, targetRole);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isOwner = member.role.toLowerCase() == 'owner';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xs,
      ),
      leading: AppAvatar(
        name: member.name,
        size: AppAvatarSize.lg,
        backgroundColor: isOwner
            ? primaryColor.withValues(alpha: 0.2)
            : theme.colorScheme.surfaceContainerHigh,
        textColor: isOwner ? primaryColor : theme.colorScheme.onSurface,
      ),
      title: Text(
        member.name,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        member.email,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: isOwner
                  ? primaryColor.withValues(alpha: 0.15)
                  : theme.colorScheme.surfaceContainerHigh,
              borderRadius: AppRadius.sm,
              border: Border.all(
                color: isOwner
                    ? primaryColor.withValues(alpha: 0.3)
                    : theme.colorScheme.outlineVariant,
              ),
            ),
            child: Text(
              isOwner ? l10n.roleOwner : l10n.roleMember,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: isOwner
                    ? primaryColor
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          AppSpacing.gapWXs,
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              size: AppIconSize.lg,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            tooltip: l10n.edit,
            onSelected: (action) {
              if (action == 'promote') {
                _confirmRoleChange(context, 'Owner');
              } else if (action == 'demote') {
                _confirmRoleChange(context, 'Member');
              } else if (action == 'remove') {
                _confirmRemoval(context);
              }
            },
            itemBuilder: (context) => [
              if (!isOwner)
                PopupMenuItem(
                  value: 'promote',
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_upward_rounded,
                        size: AppIconSize.md,
                        color: primaryColor,
                      ),
                      AppSpacing.gapWSm,
                      Text(l10n.promoteToOwner),
                    ],
                  ),
                )
              else
                PopupMenuItem(
                  value: 'demote',
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_downward_rounded,
                        size: AppIconSize.md,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      AppSpacing.gapWSm,
                      Text(l10n.demoteToMember),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_remove_outlined,
                      size: AppIconSize.md,
                      color: AppColors.error,
                    ),
                    AppSpacing.gapWSm,
                    Text(
                      l10n.removeMember,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
