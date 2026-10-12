import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/dialog/dialog.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/core/widgets/app_text_field.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/ui/widgets/quick_start_dialog.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_card.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class WorkspaceSwitcherSheet extends StatefulWidget {
  const WorkspaceSwitcherSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cubit = context.read<WorkspaceContextCubit>();
    return showAppBottomSheet<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const WorkspaceSwitcherSheet(),
      ),
    );
  }

  @override
  State<WorkspaceSwitcherSheet> createState() => _WorkspaceSwitcherSheetState();
}

class _WorkspaceSwitcherSheetState extends State<WorkspaceSwitcherSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WorkspaceContextCubit>().loadWorkspaces();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSelect(WorkspaceDto workspace) {
    context.read<WorkspaceContextCubit>().selectWorkspace(workspace);
    Navigator.of(context).pop();
  }

  void _onCreateNew() {
    final cubit = context.read<WorkspaceContextCubit>();
    final nav = Navigator.of(context);
    nav.pop();
    QuickStartDialog.show(nav.context, cubit: cubit);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppSheetDragHandle(),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Text(
                l10n.switchWorkspace,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: theme.colorScheme.onSurfaceVariant,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xs,
          ),
          child: AppTextField(
            label: '',
            hintText: l10n.searchWorkspaces,
            controller: _searchController,
            prefixIcon: Icons.search_rounded,
            onChanged: (val) =>
                setState(() => _searchQuery = val.trim().toLowerCase()),
          ),
        ),
        AppSpacing.gapHMd,
        Flexible(
          child: BlocBuilder<WorkspaceContextCubit, WorkspaceContextState>(
            builder: (context, state) {
              return state.maybeWhen(
                loaded: (workspaces, activeWorkspace) {
                  final filtered = workspaces.where((w) {
                    if (_searchQuery.isEmpty) return true;
                    return w.name.toLowerCase().contains(_searchQuery) ||
                        w.description.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: AppSpacing.edgeInsetsAllXxxl,
                        child: Text(
                          l10n.noWorkspacesFound,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.xs,
                    ),
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => AppSpacing.gapHSm,
                    itemBuilder: (context, index) {
                      final workspace = filtered[index];
                      final isActive = workspace.id == activeWorkspace.id;
                      return WorkspaceCard(
                        workspace: workspace,
                        isActive: isActive,
                        onTap: () => _onSelect(workspace),
                      );
                    },
                  );
                },
                loading: () => Center(
                  child: Padding(
                    padding: AppSpacing.edgeInsetsAllXxxl,
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
        ),

        // Pinned Bottom Button: Create New Workspace
        Padding(
          padding: AppSpacing.edgeInsetsAllXl,
          child: AppButton(
            label: l10n.createNewWorkspace,
            icon: Icons.add_rounded,
            variant: AppButtonVariant.primary,
            onPressed: _onCreateNew,
          ),
        ),
      ],
    );
  }
}
