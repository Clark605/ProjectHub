import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/workspace_accent.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/cubit/projects_list_state.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/shell/ui/widgets/desktop_sidebar_nav_item.dart';
import 'package:client/features/shell/ui/widgets/desktop_sidebar_quick_links.dart';
import 'package:client/features/shell/ui/widgets/desktop_sidebar_user_profile.dart';
import 'package:client/features/shell/models/shell_tab.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final ValueChanged<int>? onProjectSelected;
  final String? activeWorkspaceName;
  final String? activeWorkspaceAccent;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onProjectSelected,
    this.activeWorkspaceName,
    this.activeWorkspaceAccent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final activeAccentColor =
        activeWorkspaceAccent != null &&
            activeWorkspaceAccent!.trim().isNotEmpty
        ? WorkspaceAccent.fromId(
            activeWorkspaceAccent,
          ).resolvedColor(theme.brightness)
        : null;

    ProjectsListCubit? cubit;
    try {
      cubit = context.read<ProjectsListCubit>();
    } catch (_) {}

    Widget buildNavList(List<ProjectDto> projects, bool isLoading) {
      final projectsCount = projects.isNotEmpty
          ? projects.length.toString()
          : null;

      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          ...ShellTab.values.map(
            (tab) => Column(
              children: [
                DesktopSidebarNavItem(
                  icon: tab.selectedIcon,
                  label: tab == ShellTab.profile
                      ? (l10n?.profileAndSettings ?? 'Profile & Settings')
                      : (l10n != null ? tab.localizedName(l10n) : tab.label),
                  isSelected: selectedIndex == tab.index,
                  badge: tab == ShellTab.projects ? projectsCount : null,
                  badgeColor: null,
                  selectedAccentColor: activeAccentColor,
                  onTap: () => onItemSelected(tab.index),
                ),
                if (tab != ShellTab.profile) const SizedBox(height: 4),
              ],
            ),
          ),
          DesktopSidebarQuickLinks(
            projects: projects,
            isLoading: isLoading,
            onProjectSelected: onProjectSelected,
          ),
        ],
      );
    }

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        border: BorderDirectional(
          end: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        children: [
          // App Brand Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.electricViolet, AppColors.skyBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.hub_rounded,
                      color: AppColors.onElectricViolet,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'ProjectHub',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: theme.colorScheme.outlineVariant, height: 1),
          if (activeWorkspaceName != null &&
              activeWorkspaceName!.trim().isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh.withValues(
                    alpha: 0.45,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: BorderDirectional(
                    start: BorderSide(
                      color: WorkspaceAccent.fromId(
                        activeWorkspaceAccent,
                      ).resolvedColor(theme.brightness),
                      width: 3.5,
                    ),
                  ),
                ),
                child: Text(
                  activeWorkspaceName!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ] else ...[
            const SizedBox(height: 12),
          ],

          // Navigation Section
          Expanded(
            child: cubit != null
                ? BlocBuilder<ProjectsListCubit, ProjectsListState>(
                    bloc: cubit,
                    builder: (context, projectsState) {
                      final projects = projectsState.maybeWhen(
                        loaded: (_, allProjects, _) => allProjects,
                        orElse: () => const <ProjectDto>[],
                      );
                      final isLoading = projectsState.maybeWhen(
                        loading: () => true,
                        orElse: () => false,
                      );
                      return buildNavList(projects, isLoading);
                    },
                  )
                : buildNavList(const <ProjectDto>[], false),
          ),

          // User Profile & Logout Footer
          const DesktopSidebarUserProfile(),
        ],
      ),
    );
  }
}
