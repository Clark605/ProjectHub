import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/utils/permission_checker.dart';
import 'package:client/core/utils/responsive_layout.dart';
import 'package:client/core/widgets/app_error_state.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/projects/cubit/project_detail_cubit.dart';
import 'package:client/features/projects/cubit/project_detail_state.dart';
import 'package:client/features/projects/ui/widgets/project_danger_zone.dart';
import 'package:client/features/projects/ui/widgets/project_detail_skeleton.dart';
import 'package:client/features/projects/ui/widgets/project_details_card.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectId;
  final ProjectDetailCubit? cubit;

  const ProjectDetailScreen({super.key, required this.projectId, this.cubit});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late ProjectDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? getIt<ProjectDetailCubit>();
    _cubit.loadProject(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _cubit,
      child: BlocConsumer<ProjectDetailCubit, ProjectDetailState>(
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
                    _cubit.clearMessages();
                  } else if (errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    _cubit.clearError();
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
            backgroundColor: theme.colorScheme.surface,
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
            body: state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const ProjectDetailSkeleton(),
              error: (message) => AppErrorState(
                errorMessage: message,
                onRetry: () =>
                    _cubit.loadProject(widget.projectId, forceRefresh: true),
              ),
              deleted: () => const SizedBox.shrink(),
              loaded:
                  (
                    project,
                    isSaving,
                    isDeleting,
                    errorMessage,
                    actionSuccessMessage,
                  ) {
                    final currentUserId = context
                        .watch<AppAuthCubit>()
                        .state
                        .maybeWhen(
                          authenticated: (u) => u.id,
                          orElse: () => '',
                        );
                    final activeWs = context
                        .watch<WorkspaceContextCubit>()
                        .state
                        .maybeWhen(
                          loaded: (_, active) => active,
                          orElse: () => null,
                        );

                    final role =
                        activeWs?.membership?.role.toLowerCase() == 'owner'
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
          );
        },
      ),
    );
  }
}
