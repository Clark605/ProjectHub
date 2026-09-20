import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';

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
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => WorkspacePresenceSheet(
        onlineUserIds: onlineUserIds,
        members: members,
        currentUserId: currentUserId,
      ),
    );
  }

  String _getUserName(String userId) {
    final member = members.where((m) => m.userId == userId).firstOrNull;
    if (member != null && member.name.isNotEmpty) return member.name;
    if (userId == currentUserId) return 'You';
    return 'Team Member';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
              final name = _getUserName(userId);
              final initials = _getInitials(name);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHigh,
                          child: Text(
                            initials,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
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
                        isMe ? '$name (You)' : name,
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
      ),
    );
  }
}
