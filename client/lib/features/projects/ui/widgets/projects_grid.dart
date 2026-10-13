import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/utils/responsive_layout.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/ui/widgets/project_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectsGrid extends StatelessWidget {
  final List<ProjectDto> projects;
  final int? workspaceId;

  const ProjectsGrid({super.key, required this.projects, this.workspaceId});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    Future<void> handleCardTap(BuildContext context, ProjectDto project) async {
      final result = await Navigator.of(
        context,
      ).pushNamed(RouteNames.kanban, arguments: project);
      if (result == true && workspaceId != null && context.mounted) {
        await context.read<ProjectsListCubit>().loadProjects(
          workspaceId!,
          forceRefresh: true,
        );
      }
    }

    if (!isDesktop && !isTablet) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.zero,
          AppSpacing.xxl,
          AppSpacing.fabClearance,
        ),
        sliver: SliverList.separated(
          itemCount: projects.length,
          separatorBuilder: (_, _) => AppSpacing.gapHLg,
          itemBuilder: (context, index) {
            final project = projects[index];
            return ProjectCard(
              project: project,
              onTap: () => handleCardTap(context, project),
            );
          },
        ),
      );
    }

    final columns = isDesktop ? 3 : 2;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.zero,
        AppSpacing.xxl,
        AppSpacing.fabClearance,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: AppSpacing.lg,
          mainAxisSpacing: AppSpacing.lg,
          mainAxisExtent: 240,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final project = projects[index];
          return ProjectCard(
            project: project,
            onTap: () => handleCardTap(context, project),
          );
        }, childCount: projects.length),
      ),
    );
  }
}
