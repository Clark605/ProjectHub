import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/utils/responsive_layout.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/ui/widgets/project_card.dart';

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
        context.read<ProjectsListCubit>().loadProjects(
          workspaceId!,
          forceRefresh: true,
        );
      }
    }

    if (!isDesktop && !isTablet) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
        sliver: SliverList.separated(
          itemCount: projects.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
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
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
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
