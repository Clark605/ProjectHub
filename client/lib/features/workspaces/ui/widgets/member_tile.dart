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
        title: Text('Remove Member?'),
        content: Text('Are you sure you want to remove \ from the workspace?'),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOwner = member.role.toLowerCase() == 'owner';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: AppAvatar(
        name: member.name,
        size: 40,
        backgroundColor: isOwner
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.surfaceContainerHigh,
        textStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: isOwner ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      title: Text(
        member.name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        member.email,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isOwner
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.border,
              ),
            ),
            child: Text(
              isOwner ? l10n.roleOwner : l10n.roleMember,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isOwner ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
          if (!isOwner) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded, size: 18),
              color: AppColors.error,
              tooltip: l10n.removeMember,
              onPressed: () => _confirmRemoval(context),
            ),
          ],
        ],
      ),
    );
  }
}
