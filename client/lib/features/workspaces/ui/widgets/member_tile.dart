import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/app_avatar.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_cubit.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class MemberTile extends StatelessWidget {
  final MemberDto member;

  const MemberTile({super.key, required this.member});

  Future<void> _confirmRemoval(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<WorkspaceSettingsCubit>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeMemberTitle),
        content: Text(
          l10n.confirmRemoveMember(
            member.name.isNotEmpty ? member.name : member.email,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.removeMember),
          ),
        ],
      ),
    );

    if (confirm == true) {
      cubit.removeMember(member.userId);
    }
  }

  Future<void> _confirmRoleChange(
    BuildContext context,
    String targetRole,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<WorkspaceSettingsCubit>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmChangeRoleTitle),
        content: Text(
          l10n.confirmChangeRole(
            member.name.isNotEmpty ? member.name : member.email,
            targetRole == 'Owner' ? l10n.roleOwner : l10n.roleMember,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (confirm == true) {
      cubit.updateMemberRole(member.userId, targetRole);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isOwner = member.role.toLowerCase() == 'owner';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: AppAvatar(
        name: member.name,
        size: 40,
        backgroundColor: isOwner
            ? primaryColor.withValues(alpha: 0.2)
            : theme.colorScheme.surfaceContainerHigh,
        textStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: isOwner ? primaryColor : theme.colorScheme.onSurface,
        ),
      ),
      title: Text(
        member.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: theme.colorScheme.onSurface,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        member.email,
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isOwner
                  ? primaryColor.withValues(alpha: 0.15)
                  : theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isOwner
                    ? primaryColor.withValues(alpha: 0.3)
                    : theme.colorScheme.outlineVariant,
              ),
            ),
            child: Text(
              isOwner ? l10n.roleOwner : l10n.roleMember,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isOwner
                    ? primaryColor
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              size: 20,
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
                        size: 18,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 8),
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
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
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
                      size: 18,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.removeMember,
                      style: const TextStyle(color: AppColors.error),
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
