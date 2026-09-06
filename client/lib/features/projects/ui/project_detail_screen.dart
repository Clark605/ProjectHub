import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/utils/permission_checker.dart';
import 'package:client/core/utils/responsive_layout.dart';
import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/projects/cubit/project_detail_cubit.dart';
import 'package:client/features/projects/cubit/project_detail_state.dart';
import 'package:client/features/projects/ui/widgets/project_danger_zone.dart';
import 'package:client/features/projects/ui/widgets/project_details_card.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/l10n/generated/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProjectDetailScreen extends StatelessWidget {
  final int projectId;
  final ProjectDetailCubit? cubit;

  const ProjectDetailScreen({super.key, required this.projectId, this.cubit});

  static ProjectDetailCubit? _findProjectDetailCubit(BuildContext context) {
    try {
      return context.read<ProjectDetailCubit>();
    } catch (_) {
      return null;
    }
  }

  static AppAuthCubit? _findAuthCubit(BuildContext context) {
    try {
      return context.read<AppAuthCubit>();
    } catch (_) {
      return getIt.isRegistered<AppAuthCubit>() ? getIt<AppAuthCubit>() : null;
    }
  }

  static WorkspaceContextCubit? _findWorkspaceContextCubit(
    BuildContext context,
  ) {
    try {
      return context.read<WorkspaceContextCubit>();
    } catch (_) {
      return getIt.isRegistered<WorkspaceContextCubit>()
          ? getIt<WorkspaceContextCubit>()
          : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = BlocConsumer<ProjectDetailCubit, ProjectDetailState>(
      listener: (context, state) {
        state.maybeWhen(
          deleted: () {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.projectDeleted),
                backgroundColor: AppColors.surfaceContainerHigh,
              ),
            );
            Navigator.of(context).pop(true);
          },
          loaded:
              (
                project,
                isSaving,
                isDeleting,
                errorMessage,
                actionSuccessMessage,
              ) {
                final l10n = AppLocalizations.of(context)!;
                if (actionSuccessMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.projectUpdated),
                      backgroundColor: AppColors.surfaceContainerHigh,
                    ),
                  );
                  context.read<ProjectDetailCubit>().clearMessages();
                } else if (errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  context.read<ProjectDetailCubit>().clearError();
                }
              },
          orElse: () {},
        );
      },
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        final isDesktop = ResponsiveLayout.isDesktop(context);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              l10n.projectDetails,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: AmbientGlowBackground(
            child: state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => _buildSkeleton(context),
              error: (message) => _buildError(context, message),
              deleted: () => const SizedBox.shrink(),
              loaded:
                  (
                    project,
                    isSaving,
                    isDeleting,
                    errorMessage,
                    actionSuccessMessage,
                  ) {
                    // Resolve user and workspace role for permissions
                    final authState = context.watch<AppAuthCubit>().state;
                    final currentUserId = authState.maybeWhen(
                      authenticated: (u) => u.id,
                      orElse: () => '',
                    );

                    final wsState = context
                        .watch<WorkspaceContextCubit>()
                        .state;
                    final activeWs = wsState.maybeWhen(
                      loaded: (_, active) => active,
                      orElse: () => null,
                    );

                    final isOwner =
                        activeWs?.membership?.role.toLowerCase() == 'owner';
                    final role = isOwner
                        ? 'owner'
                        : 'member';

                    final canEdit = PermissionChecker.canEditProject(
                      role: role,
                      projectCreatorId: project.createdBy,
                      currentUserId: currentUserId,
                    );

                    final canDelete = PermissionChecker.canDeleteProject(
                      role: role,
                      projectCreatorId: project.createdBy,
                      currentUserId: currentUserId,
                    );

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 48 : 20,
                        vertical: 24,
                      ),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ProjectDetailsCard(canEdit: canEdit),
                              if (canDelete) ...[
                                const SizedBox(height: 24),
                                ProjectDangerZone(canDelete: canDelete),
                              ],
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
            ),
          ),
        );
      },
    );

    // Provide ProjectDetailCubit
    final existingDetailCubit = cubit ?? _findProjectDetailCubit(context);
    if (existingDetailCubit != null) {
      content = BlocProvider<ProjectDetailCubit>.value(
        value: existingDetailCubit..loadProject(projectId),
        child: content,
      );
    } else {
      content = BlocProvider<ProjectDetailCubit>(
        create: (_) => getIt<ProjectDetailCubit>()..loadProject(projectId),
        child: content,
      );
    }

    // Ensure WorkspaceContextCubit is provided
    final effectiveWsCubit = _findWorkspaceContextCubit(context);
    if (effectiveWsCubit != null) {
      content = BlocProvider<WorkspaceContextCubit>.value(
        value: effectiveWsCubit,
        child: content,
      );
    }

    // Ensure AppAuthCubit is provided
    final effectiveAuthCubit = _findAuthCubit(context);
    if (effectiveAuthCubit != null) {
      content = BlocProvider<AppAuthCubit>.value(
        value: effectiveAuthCubit,
        child: content,
      );
    }

    return content;
  }

  Widget _buildSkeleton(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Bone.text(words: 2, fontSize: 18),
                      const SizedBox(height: 16),
                      Bone(
                        width: double.infinity,
                        height: 48,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(height: 16),
                      Bone(
                        width: double.infinity,
                        height: 80,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(height: 16),
                      Bone(
                        width: double.infinity,
                        height: 48,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<ProjectDetailCubit>().loadProject(
                  projectId,
                  forceRefresh: true,
                );
              },
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
