import 'package:flutter/material.dart';

import 'package:client/core/dialog/app_bottom_sheet.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_avatar_size.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/widgets/app_avatar.dart';
import 'package:client/core/widgets/status_dot.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class WorkspacePresenceSheet extends StatelessWidget {
  const WorkspacePresenceSheet({
    super.key,
    required this.onlineUserIds,
    required this.members,
    required this.currentUserId,
  });

  final List<String> onlineUserIds;
  final List<MemberDto> members;
  final String currentUserId;

  static void show(
    BuildContext context, {
    required List<String> onlineUserIds,
    required List<MemberDto> members,
    required String currentUserId,
  }) {
    showAppBottomSheet<void>(
      context: context,
      builder: (_) => WorkspacePresenceSheet(
        onlineUserIds: onlineUserIds,
        members: members,
        currentUserId: currentUserId,
      ),
    );
  }

  String _getUserName(String userId, AppLocalizations l10n) {
    final member = members.where((m) => m.userId == userId).firstOrNull;
    if (member != null && member.name.isNotEmpty) return member.name;
    if (userId == currentUserId) return l10n.you;
    return l10n.teamMember;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSheetDragHandle(),
          AppSpacing.gapHMd,
          Row(
            children: [
              const StatusDot(color: AppColors.success),
              AppSpacing.gapWSm,
              Text(
                l10n.onlineMembersCount(onlineUserIds.length),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.gapHMd,
          ...onlineUserIds.map((userId) {
            final isMe = userId == currentUserId;
            final name = _getUserName(userId, l10n);

            return Padding(
              padding: AppSpacing.edgeInsetsVXs,
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AppAvatar(
                        name: name,
                        size: AppAvatarSize.compact,
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Positioned(
                        right: -1,
                        bottom: -1,
                        child: StatusDot(
                          color: AppColors.success,
                          borderColor: theme.colorScheme.surface,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapWMd,
                  Expanded(
                    child: Text(
                      isMe ? l10n.youSuffix(name) : name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isMe ? FontWeight.w600 : FontWeight.normal,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
