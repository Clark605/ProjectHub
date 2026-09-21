import 'dart:async';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:flutter/material.dart';

import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/core/di/injection.dart';
import 'package:client/core/network/signalr_events.dart';
import 'package:client/core/network/signalr_service.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_avatar_item.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_presence_sheet.dart';

class WorkspacePresenceAvatars extends StatefulWidget {
  const WorkspacePresenceAvatars({
    super.key,
    required this.workspaceId,
    this.signalRService,
  });

  final int workspaceId;
  final SignalRService? signalRService;

  @override
  State<WorkspacePresenceAvatars> createState() =>
      _WorkspacePresenceAvatarsState();
}

class _WorkspacePresenceAvatarsState extends State<WorkspacePresenceAvatars> {
  StreamSubscription<PresenceChangedEvent>? _presenceSub;
  List<String> _onlineUserIds = [];
  List<MemberDto> _members = [];

  String get _currentUserId {
    if (!getIt.isRegistered<AppAuthCubit>()) return '';
    return getIt<AppAuthCubit>().state.whenOrNull(authenticated: (u) => u.id) ??
        '';
  }

  @override
  void initState() {
    super.initState();
    _loadMembers();
    final service =
        widget.signalRService ??
        (getIt.isRegistered<SignalRService>() ? getIt<SignalRService>() : null);
    if (service != null) {
      service.joinWorkspace(widget.workspaceId);
      _presenceSub = service.presenceChanged.listen((event) {
        if (event.workspaceId == widget.workspaceId && mounted) {
          setState(() {
            _onlineUserIds = event.onlineUserIds;
          });
        }
      });
    }
  }

  void _loadMembers() {
    final repo = getIt.isRegistered<WorkspaceRepository>()
        ? getIt<WorkspaceRepository>()
        : null;
    if (repo != null) {
      repo
          .getMembers(widget.workspaceId)
          .then((m) {
            if (mounted) setState(() => _members = m);
          })
          .catchError((_) {});
    }
  }

  @override
  void didUpdateWidget(covariant WorkspacePresenceAvatars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workspaceId != widget.workspaceId) {
      _onlineUserIds = [];
      _loadMembers();
      final service =
          widget.signalRService ??
          (getIt.isRegistered<SignalRService>()
              ? getIt<SignalRService>()
              : null);
      service?.joinWorkspace(widget.workspaceId);
    }
  }

  @override
  void dispose() {
    _presenceSub?.cancel();
    super.dispose();
  }

  Widget _buildAvatarStack(ThemeData theme) {
    final visibleCount = _onlineUserIds.length > 3 ? 3 : _onlineUserIds.length;
    final visibleIds = _onlineUserIds.take(visibleCount).toList();
    final overflowCount = _onlineUserIds.length - visibleCount;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < visibleIds.length; i++)
          Align(
            widthFactor: (i == visibleIds.length - 1 && overflowCount == 0)
                ? 1.0
                : 0.72,
            child: WorkspaceAvatarItem(
              userId: visibleIds[i],
              member: _members
                  .where((m) => m.userId == visibleIds[i])
                  .firstOrNull,
              isMe: visibleIds[i] == _currentUserId,
              radius: 12,
            ),
          ),
        if (overflowCount > 0)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.surface, width: 1.5),
            ),
            child: Center(
              child: Text(
                '+$overflowCount',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_onlineUserIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Tooltip(
      message: '${_onlineUserIds.length} online member(s)',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          WorkspacePresenceSheet.show(
            context,
            onlineUserIds: _onlineUserIds,
            members: _members,
            currentUserId: _currentUserId,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh.withValues(
              alpha: 0.6,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              _buildAvatarStack(theme),
            ],
          ),
        ),
      ),
    );
  }
}
