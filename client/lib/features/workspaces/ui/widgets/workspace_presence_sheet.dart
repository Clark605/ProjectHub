import 'package:flutter/material.dart';

import 'package:client/core/dialog/app_bottom_sheet.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/app_avatar.dart';
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

  String _getUserName(String userId, AppLocalizations? l10n) {
    final member = members.where((m) => m.userId == userId).firstOrNull;
    if (member != null && member.name.isNotEmpty) return member.name;
    if (userId == currentUserId) return l10n?.you ?? 'You';
    return l10n?.teamMember ?? 'Team Member';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSheetDragHandle(),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n?.onlineMembersCount(onlineUserIds.length) ??
                    'Online Members (${onlineUserIds.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...onlineUserIds.map((userId) {
            final isMe = userId == currentUserId;
            final name = _getUserName(userId, l10n);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AppAvatar(
                        userId: userId,
                        name: name,
                        size: 28,
                        textStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Positioned(
                        right: -1,
                        bottom: -1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isMe ? (l10n?.youSuffix(name) ?? '$name (You)') : name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isMe
                              ? FontWeight.w600
                              : FontWeight.normal,
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
