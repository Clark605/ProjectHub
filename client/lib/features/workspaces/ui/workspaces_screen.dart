import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_state.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_danger_zone.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_details_card.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_error_banner.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_members_card.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_settings_skeleton.dart';
import 'package:client/l10n/generated/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WorkspacesScreen extends StatelessWidget {
  final WorkspaceSettingsCubit? cubit;
  final WorkspaceContextCubit? contextCubit;

  const WorkspacesScreen({super.key, this.cubit, this.contextCubit});

  static WorkspaceContextCubit? _findContextCubit(BuildContext context) {
    try {
      return context.read<WorkspaceContextCubit>();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const _WorkspaceSettingsView();

    if (cubit != null) {
      content = BlocProvider<WorkspaceSettingsCubit>.value(
        value: cubit!,
        child: content,
      );
    } else {
      content = BlocProvider<WorkspaceSettingsCubit>(
        create: (_) => getIt<WorkspaceSettingsCubit>(),
        child: content,
      );
    }

    final effectiveContextCubit =
        contextCubit ??
        _findContextCubit(context) ??
        (getIt.isRegistered<WorkspaceContextCubit>()
            ? getIt<WorkspaceContextCubit>()
            : null);

    if (effectiveContextCubit != null) {
      content = BlocProvider<WorkspaceContextCubit>.value(
        value: effectiveContextCubit,
        child: content,
      );
    }

    return content;
  }
}

class _WorkspaceSettingsView extends StatefulWidget {
  const _WorkspaceSettingsView();

  @override
  State<_WorkspaceSettingsView> createState() => _WorkspaceSettingsViewState();
}

class _WorkspaceSettingsViewState extends State<_WorkspaceSettingsView> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<WorkspaceSettingsCubit>();
    if (cubit.state is WorkspaceSettingsInitial) {
      final active = context.read<WorkspaceContextCubit>().state.mapOrNull(
        loaded: (s) => s.activeWorkspace,
      );
      if (active != null) {
        cubit.loadSettings(active.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final activeWorkspace = context
        .watch<WorkspaceContextCubit>()
        .state
        .mapOrNull(loaded: (s) => s.activeWorkspace);

    final isOwner = activeWorkspace?.membership?.role.toLowerCase() == 'owner';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workspaceSettings),
        actions: [
          if (activeWorkspace != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    activeWorkspace.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: !isOwner
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.ownerOnlyAccess,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Return to Workspace'),
                    ),
                  ],
                ),
              ),
            )
          : BlocConsumer<WorkspaceSettingsCubit, WorkspaceSettingsState>(
              listener: (context, state) {
                if (state is WorkspaceSettingsDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.workspaceDeleted)),
                  );
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(RouteNames.shell, (route) => false);
                } else if (state is WorkspaceSettingsLoaded) {
                  if (state.actionSuccessMessage != null) {
                    final raw = state.actionSuccessMessage!;
                    final String msg;
                    if (raw.startsWith('memberAddedWithEmail:')) {
                      final email = raw.substring(
                        'memberAddedWithEmail:'.length,
                      );
                      msg = l10n.memberAddedWithEmail(email);
                    } else if (raw == 'detailsUpdated') {
                      msg = l10n.detailsUpdated;
                    } else if (raw == 'memberAdded') {
                      msg = l10n.memberAdded;
                    } else if (raw == 'memberRemoved') {
                      msg = l10n.memberRemoved;
                    } else {
                      msg = raw;
                    }
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(msg)));
                    context.read<WorkspaceSettingsCubit>().clearMessages();
                  }
                }
              },
              builder: (context, state) {
                if (state is WorkspaceSettingsLoading) {
                  return const WorkspaceSettingsSkeleton();
                }
                if (state is WorkspaceSettingsError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (activeWorkspace != null) {
                              context
                                  .read<WorkspaceSettingsCubit>()
                                  .loadSettings(
                                    activeWorkspace.id,
                                    forceRefresh: true,
                                  );
                            }
                          },
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  );
                }

                final isRevalidating =
                    state is WorkspaceSettingsLoaded && state.isRevalidating;
                final errorMessage = state is WorkspaceSettingsLoaded
                    ? state.errorMessage
                    : null;

                return Skeletonizer(
                  enabled: isRevalidating,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (errorMessage != null)
                              WorkspaceErrorBanner(message: errorMessage),
                            const WorkspaceDetailsCard(),
                            const SizedBox(height: 24),
                            const WorkspaceMembersCard(),
                            const SizedBox(height: 24),
                            const WorkspaceDangerZone(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
