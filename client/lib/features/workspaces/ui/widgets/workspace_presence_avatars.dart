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

  String _getLabel() {
    final count = _onlineUserIds.length;
    if (count == 1) {
      if (_onlineUserIds.first == _currentUserId) {
        return '1 online (You)';
      }
      final other = _members
          .where((m) => m.userId == _onlineUserIds.first)
          .firstOrNull;
      if (other != null && other.name.isNotEmpty) {
        return other.name.split(' ').first;
      }
    }
    return '$count online';
  }

  @override
  Widget build(BuildContext context) {
    if (_onlineUserIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        WorkspacePresenceSheet.show(
          context,
          onlineUserIds: _onlineUserIds,
          members: _members,
          currentUserId: _currentUserId,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _getLabel(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
