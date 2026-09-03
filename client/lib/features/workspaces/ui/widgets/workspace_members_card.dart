import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_state.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/ui/widgets/invite_member_sheet.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class WorkspaceMembersCard extends StatelessWidget {
  const WorkspaceMembersCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocBuilder<WorkspaceSettingsCubit, WorkspaceSettingsState>(
      builder: (context, state) {
        if (state is! WorkspaceSettingsLoaded) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      l10n.teamMembers,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.membersCount(state.members.length),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => InviteMemberSheet.show(context),
                      icon: const Icon(Icons.person_add_outlined, size: 18),
                      label: Text(l10n.addMember),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.members.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final member = state.members[index];
                  return _MemberTile(member: member);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MemberTile extends StatelessWidget {
  final MemberDto member;

  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOwner = member.role.toLowerCase() == 'owner';
    final initials = member.name.isNotEmpty
        ? member.name.substring(0, member.name.length >= 2 ? 2 : 1).toUpperCase()
        : 'U';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: isOwner
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.surfaceContainerHigh,
        child: Text(
          initials,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: isOwner ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
      title: Text(
        member.name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        member.email,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
              onPressed: () {
                context.read<WorkspaceSettingsCubit>().removeMember(member.userId);
              },
            ),
          ],
        ],
      ),
    );
  }
}
