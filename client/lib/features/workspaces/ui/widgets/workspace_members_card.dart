import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_state.dart';

import 'package:client/features/workspaces/ui/widgets/invite_member_sheet.dart';
import 'package:client/features/workspaces/ui/widgets/member_tile.dart';
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
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 400;

                    final badge = Container(
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
                    );

                    final actionButton = TextButton.icon(
                      onPressed: () => InviteMemberSheet.show(context),
                      icon: const Icon(Icons.person_add_outlined, size: 18),
                      label: Text(l10n.addMember),
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  l10n.teamMembers,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              badge,
                            ],
                          ),
                          const SizedBox(height: 8),
                          actionButton,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Flexible(
                          child: Text(
                            l10n.teamMembers,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        badge,
                        const Spacer(),
                        actionButton,
                      ],
                    );
                  },
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
                  return MemberTile(member: member);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
