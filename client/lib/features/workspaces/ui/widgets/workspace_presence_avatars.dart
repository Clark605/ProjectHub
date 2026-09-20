import 'dart:async';
import 'package:flutter/material.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/network/signalr_events.dart';
import 'package:client/core/network/signalr_service.dart';
import 'package:client/core/theme/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
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

  @override
  void didUpdateWidget(covariant WorkspacePresenceAvatars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workspaceId != widget.workspaceId) {
      _onlineUserIds = [];
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

  @override
  Widget build(BuildContext context) {
    if (_onlineUserIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final count = _onlineUserIds.length;

    return Container(
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
            '$count online',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
