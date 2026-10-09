import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_presence_avatars.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    int? activeWsId;
    try {
      final wsState = context.watch<WorkspaceContextCubit>().state;
      activeWsId = wsState.mapOrNull(loaded: (l) => l.activeWorkspace.id);
    } on Object catch (_) {
      // Allows rendering DashboardHeader in isolated widget tests without WorkspaceContextCubit
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.workspaceOverview,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.workspaceOverviewSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (activeWsId != null) ...[
          const SizedBox(width: 12),
          WorkspacePresenceAvatars(workspaceId: activeWsId),
        ],
      ],
    );
  }
}
