import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';

class WorkspaceAvatarItem extends StatelessWidget {
  final String userId;
  final MemberDto? member;
  final bool isMe;
  final double radius;

  const WorkspaceAvatarItem({
    super.key,
    required this.userId,
    this.member,
    this.isMe = false,
    this.radius = 12,
  });

  String get _name {
    if (member != null && member!.name.isNotEmpty) {
      return member!.name;
    }
    return userId.length > 8 ? userId.substring(0, 8) : userId;
  }

  String get _initials {
    final parts = _name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Color _getBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    final hash = userId.hashCode.abs();
    final colors = [
      AppColors.skyBlue.withValues(alpha: 0.25),
      AppColors.electricViolet.withValues(alpha: 0.25),
      AppColors.success.withValues(alpha: 0.25),
      AppColors.warning.withValues(alpha: 0.25),
      AppColors.priorityUrgent.withValues(alpha: 0.25),
    ];
    return theme.brightness == Brightness.dark
        ? colors[hash % colors.length]
        : theme.colorScheme.primaryContainer;
  }

  Color _getTextColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppColors.textPrimary
        : theme.colorScheme.onPrimaryContainer;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tooltip = isMe ? '$_name (You)' : _name;

    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorScheme.surface, width: 1.5),
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: _getBackgroundColor(context),
          child: Text(
            _initials,
            style: TextStyle(
              fontSize: radius * 0.75,
              fontWeight: FontWeight.w700,
              color: _getTextColor(context),
            ),
          ),
        ),
      ),
    );
  }
}
