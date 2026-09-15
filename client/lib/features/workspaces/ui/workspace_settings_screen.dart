import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_state.dart';
import 'package:client/core/widgets/app_danger_zone.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_details_card.dart';
import 'package:client/core/widgets/app_error_banner.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_members_card.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_settings_skeleton.dart';
import 'package:client/l10n/generated/app_localizations.dart';
import 'package:client/core/widgets/app_snackbar.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_access_denied_view.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WorkspaceSettingsScreen extends StatelessWidget {
  final WorkspaceSettingsCubit? cubit;
  final WorkspaceContextCubit? contextCubit;

  const WorkspaceSettingsScreen({super.key, this.cubit, this.contextCubit});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        if (cubit != null)
          BlocProvider.value(value: cubit!)
        else
          BlocProvider(create: (_) => getIt<WorkspaceSettingsCubit>()),
        if (contextCubit != null)
          BlocProvider.value(value: contextCubit!)
        else if (getIt.isRegistered<WorkspaceContextCubit>())
          BlocProvider.value(value: getIt<WorkspaceContextCubit>()),
      ],
      child: const _View(),
    );
  }
}

class _View extends StatefulWidget {
  const _View();
  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<WorkspaceSettingsCubit>();
    if (cubit.state is WorkspaceSettingsInitial) {
      final active = context.read<WorkspaceContextCubit>().state.whenOrNull(
        loaded: (workspaces, active) => active,
      );
      if (active != null) cubit.loadSettings(active.id);
    }
  }

  void _onState(BuildContext context, WorkspaceSettingsState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state is WorkspaceSettingsDeleted) {
      context.showSuccessSnackBar(l10n.workspaceDeleted);
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(RouteNames.shell, (r) => false);
    } else if (state is WorkspaceSettingsLoaded &&
        state.successAction != null) {
      final action = state.successAction!;
      final msg = switch (action) {
        ActionMemberAddedWithEmail(email: final e) => l10n.memberAddedWithEmail(
          e,
        ),
        ActionDetailsUpdated() => l10n.detailsUpdated,
        ActionMemberAdded() => l10n.memberAdded,
        ActionMemberRemoved() => l10n.memberRemoved,
      };
      if (msg.isNotEmpty) context.showSuccessSnackBar(msg);
      context.read<WorkspaceSettingsCubit>().clearMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final active = context.watch<WorkspaceContextCubit>().state.whenOrNull(
      loaded: (workspaces, active) => active,
    );
    final isOwner = active?.membership?.role.toLowerCase() == 'owner';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workspaceSettings, style: theme.textTheme.titleMedium),
        actions: [
          if (active != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    active.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: !isOwner
          ? const WorkspaceAccessDeniedView()
          : BlocConsumer<WorkspaceSettingsCubit, WorkspaceSettingsState>(
              listener: _onState,
              builder: (context, state) {
                if (state is WorkspaceSettingsLoading ||
                    state is WorkspaceSettingsInitial) {
                  return const WorkspaceSettingsSkeleton();
                }
                if (state is WorkspaceSettingsError) {
                  return Center(child: Text(state.message));
                }
                if (state is! WorkspaceSettingsLoaded) {
                  return const SizedBox.shrink();
                }

                final loaded = state;
                return Skeletonizer(
                  enabled: loaded.isRevalidating,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (loaded.errorMessage != null)
                              AppErrorBanner(
                                errorMessage: loaded.errorMessage!,
                                onDismiss: () => context
                                    .read<WorkspaceSettingsCubit>()
                                    .clearError(),
                              ),
                            const WorkspaceDetailsCard(),
                            const SizedBox(height: 24),
                            const WorkspaceMembersCard(),
                            const SizedBox(height: 24),
                            AppDangerZone(
                              title: l10n.deleteWorkspace,
                              description: l10n.deleteWorkspaceWarning,
                              entityName: active?.name ?? l10n.workspaceName,
                              onDelete: () => context
                                  .read<WorkspaceSettingsCubit>()
                                  .deleteWorkspace(),
                            ),
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
