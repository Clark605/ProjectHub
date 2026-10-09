import 'package:flutter/material.dart';

import 'package:client/core/widgets/app_avatar.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tooltip = isMe ? '$_name (You)' : _name;

    return Tooltip(
      message: tooltip,
      child: AppAvatar(
        name: _name,
        userId: userId,
        size: radius * 2,
        border: Border.all(color: theme.colorScheme.surface, width: 1.5),
      ),
    );
  }
}
