import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/features/projects/ui/widgets/project_card.dart';
import 'package:client/features/projects/ui/widgets/projects_filter_bar.dart';

class ProjectsScreen extends StatefulWidget {
  final VoidCallback? onCreateProject;

  const ProjectsScreen({super.key, this.onCreateProject});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String _selectedFilter = 'All';
  final _searchController = TextEditingController();

  final List<String> _filters = ['All', 'Active', 'Planning', 'Completed'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header & Action ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Projects',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Organize, track deliverables, and manage Kanban sprint boards.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: AppButton(
                  label: 'New Project',
                  icon: Icons.add_rounded,
                  onPressed: widget.onCreateProject ?? () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Filter Chips & Search Bar ──
          ProjectsFilterBar(
            searchController: _searchController,
            selectedFilter: _selectedFilter,
            filters: _filters,
            onFilterSelected: (f) => setState(() => _selectedFilter = f),
          ),
          const SizedBox(height: 24),

          // ── Projects Grid ──
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1100
                  ? 3
                  : constraints.maxWidth > 700
                      ? 2
                      : 1;

              final sampleProjects = [
                const ProjectCardData(
                  title: 'Mobile Client v1',
                  description:
                      'Flutter cross-platform client with ambient glowing theme & offline-ready architecture.',
                  status: 'Active',
                  statusColor: AppColors.success,
                  tasksCount: 18,
                  membersCount: 4,
                  dueDate: 'Sep 30, 2026',
                ),
                const ProjectCardData(
                  title: 'Design System — Deep Slate',
                  description:
                      'Figma tokens, cyber-modern components, and accessibility color contrast audit.',
                  status: 'Active',
                  statusColor: AppColors.success,
                  tasksCount: 12,
                  membersCount: 3,
                  dueDate: 'Oct 15, 2026',
                ),
                const ProjectCardData(
                  title: 'Backend API 10',
                  description:
                      'ASP.NET Core 10 Web API with PostgreSQL EF Core, HybridCache, and JWT token rotation.',
                  status: 'Planning',
                  statusColor: AppColors.skyBlue,
                  tasksCount: 8,
                  membersCount: 2,
                  dueDate: 'Nov 01, 2026',
                ),
              ];

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: sampleProjects.map((p) {
                  final cardWidth = crossAxisCount == 1
                      ? constraints.maxWidth
                      : (constraints.maxWidth - (crossAxisCount - 1) * 16) /
                          crossAxisCount;

                  return SizedBox(
                    width: cardWidth,
                    child: ProjectCard(data: p),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
