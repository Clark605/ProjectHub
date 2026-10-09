import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:client/core/di/injection.dart';
import 'package:client/core/network/signalr_service.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RealtimeStatusBadge extends StatelessWidget {
  const RealtimeStatusBadge({
    super.key,
    this.signalRService,
    this.showLabel = false,
  });

  final SignalRService? signalRService;
  final bool showLabel;

  SignalRService? _resolveSignalR(BuildContext context) {
    if (signalRService != null) return signalRService;
    try {
      return context.read<SignalRService>();
    } on Object catch (_) {
      // Allow fallback to GetIt locator when outside a provider tree
    }
    try {
      return getIt<SignalRService>();
    } on Object catch (_) {
      // Safe fallback when running in isolated tests without SignalR service
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final signalR = _resolveSignalR(context);
    if (signalR == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<RealtimeStatus>(
      stream: signalR.realtimeStatus,
      initialData: signalR.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? RealtimeStatus.disconnected;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final Color dotColor;
        final String tooltip;
        final String label;

        switch (status) {
          case RealtimeStatus.connected:
            dotColor = AppColors.success;
            tooltip = 'Live: Real-time updates active';
            label = 'Live';
            break;
          case RealtimeStatus.reconnecting:
            dotColor = AppColors.warning;
            tooltip = 'Reconnecting: Attempting to reconnect...';
            label = 'Reconnecting';
            break;
          case RealtimeStatus.disconnected:
            dotColor = isDark ? AppColors.textTertiary : AppColors.lightBorder;
            tooltip = 'Offline: Real-time sync paused';
            label = 'Offline';
            break;
        }

        return Tooltip(
          message: tooltip,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: showLabel ? 8 : 4,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: dotColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.r12,
              border: Border.all(
                color: dotColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: status == RealtimeStatus.connected
                        ? [
                            BoxShadow(
                              color: dotColor.withValues(alpha: 0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
                if (showLabel) ...[
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: dotColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
