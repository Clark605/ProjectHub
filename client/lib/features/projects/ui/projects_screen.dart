import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/core/widgets/app_text_field.dart';

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
              Column(
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
          Row(
            children: [
              Expanded(
                flex: 4,
                child: AppTextField(
                  label: '',
                  hintText: 'Search projects by name...',
                  prefixIcon: Icons.search_rounded,
                  controller: _searchController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedFilter = filter);
                            }
                          },
                          backgroundColor: AppColors.surfaceContainer,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.textOnPrimary
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Projects Grid Placeholder ──
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1100
                  ? 3
                  : constraints.maxWidth > 700
                      ? 2
                      : 1;

              final sampleProjects = [
                _ProjectCardData(
                  title: 'Mobile Client v1',
                  description:
                      'Flutter cross-platform client with ambient glowing theme & offline-ready architecture.',
                  status: 'Active',
                  statusColor: AppColors.success,
                  tasksCount: 18,
                  membersCount: 4,
                  dueDate: 'Sep 30, 2026',
                ),
                _ProjectCardData(
                  title: 'Design System — Deep Slate',
                  description:
                      'Figma tokens, cyber-modern components, and accessibility color contrast audit.',
                  status: 'Active',
                  statusColor: AppColors.success,
                  tasksCount: 12,
                  membersCount: 3,
                  dueDate: 'Oct 15, 2026',
                ),
                _ProjectCardData(
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
                    child: _ProjectItemCard(data: p),
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

class _ProjectCardData {
  final String title;
  final String description;
  final String status;
  final Color statusColor;
  final int tasksCount;
  final int membersCount;
  final String dueDate;

  _ProjectCardData({
    required this.title,
    required this.description,
    required this.status,
    required this.statusColor,
    required this.tasksCount,
    required this.membersCount,
    required this.dueDate,
  });
}

class _ProjectItemCard extends StatelessWidget {
  final _ProjectCardData data;

  const _ProjectItemCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: data.statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: data.statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  data.status,
                  style: TextStyle(
                    color: data.statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    data.dueDate,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.check_box_outlined,
                    size: 15,
                    color: AppColors.electricViolet,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${data.tasksCount} Tasks',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.people_alt_outlined,
                    size: 15,
                    color: AppColors.skyBlue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${data.membersCount} Members',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
