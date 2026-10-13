import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_state.dart';
import 'package:client/features/workspaces/ui/widgets/invite_member_sheet.dart';
import 'package:client/features/workspaces/ui/widgets/member_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkspaceMembersCard extends StatelessWidget {
  const WorkspaceMembersCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<WorkspaceSettingsCubit, WorkspaceSettingsState>(
      builder: (context, state) {
        if (state is! WorkspaceSettingsLoaded) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: AppRadius.lg,
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: AppSpacing.edgeInsetsAllXl,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 400;

                    final badge = Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHigh,
                        borderRadius: AppRadius.md,
                      ),
                      child: Text(
                        l10n.membersCount(state.members.length),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );

                    final actionButton = TextButton.icon(
                      onPressed: () => InviteMemberSheet.show(context),
                      icon: const Icon(
                        Icons.person_add_outlined,
                        size: AppIconSize.md,
                      ),
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
                              AppSpacing.gapWSm,
                              badge,
                            ],
                          ),
                          AppSpacing.gapHSm,
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
                        AppSpacing.gapWSm,
                        badge,
                        const Spacer(),
                        actionButton,
                      ],
                    );
                  },
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.members.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
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
