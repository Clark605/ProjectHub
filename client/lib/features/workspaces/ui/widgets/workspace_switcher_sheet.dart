import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/core/widgets/app_text_field.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/ui/widgets/quick_start_dialog.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_card.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class WorkspaceSwitcherSheet extends StatefulWidget {
  const WorkspaceSwitcherSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WorkspaceSwitcherSheet(),
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
    getIt<WorkspaceContextCubit>().loadWorkspaces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSelect(WorkspaceDto workspace) {
    getIt<WorkspaceContextCubit>().selectWorkspace(workspace);
    Navigator.of(context).pop();
  }

  void _onCreateNew() {
    Navigator.of(context).pop();
    QuickStartDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocProvider.value(
      value: getIt<WorkspaceContextCubit>(),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        padding: EdgeInsets.only(bottom: bottomInset),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Pill Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    l10n.switchWorkspace,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.textSecondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: AppTextField(
                label: l10n.searchWorkspaces,
                hintText: l10n.searchWorkspaces,
                controller: _searchController,
                prefixIcon: Icons.search_rounded,
                onChanged: (val) =>
                    setState(() => _searchQuery = val.trim().toLowerCase()),
              ),
            ),
            const SizedBox(height: 12),

            // Workspaces List
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
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              l10n.noWorkspacesFound,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
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
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
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
              padding: const EdgeInsets.all(20),
              child: AppButton(
                label: l10n.createNewWorkspace,
                icon: Icons.add_rounded,
                variant: AppButtonVariant.primary,
                onPressed: _onCreateNew,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
