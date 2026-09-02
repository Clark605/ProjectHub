import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/app_button.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  String _activeTab = 'Assigned to Me';

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
                    'My Tasks',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Daily focus, urgent blockers, and sprint deliverables assigned to you.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: AppButton(
                  label: 'Add Task',
                  icon: Icons.add_task_rounded,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Tab Switcher ──
          Row(
            children: ['Assigned to Me', 'Created by Me', 'Completed'].map((tab) {
              final isSelected = _activeTab == tab;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () => setState(() => _activeTab = tab),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ── Section 1: Urgent & Blocker Items ──
          _buildTaskSection(
            context,
            theme,
            title: '🚨 Urgent & High Priority',
            color: AppColors.priorityUrgent,
            tasks: [
              _UserTaskItem(
                title: 'Implement Refresh Token Queue Interceptor',
                project: 'Mobile Client v1',
                status: 'In Progress',
                statusColor: AppColors.skyBlue,
                priority: 'Urgent',
                priorityColor: AppColors.priorityUrgent,
                dueDate: 'Due Today',
              ),
              _UserTaskItem(
                title: 'Resolve Multi-Session Refresh Token Cascade',
                project: 'Backend API 10',
                status: 'Todo',
                statusColor: AppColors.electricViolet,
                priority: 'High',
                priorityColor: AppColors.priorityHigh,
                dueDate: 'Tomorrow',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Section 2: In Progress & Active Tasks ──
          _buildTaskSection(
            context,
            theme,
            title: '⚡ In Progress',
            color: AppColors.skyBlue,
            tasks: [
              _UserTaskItem(
                title: 'Build Responsive Shell with Fixed 240px Sidebar',
                project: 'Mobile Client v1',
                status: 'In Progress',
                statusColor: AppColors.skyBlue,
                priority: 'Medium',
                priorityColor: AppColors.priorityMedium,
                dueDate: 'Sep 04',
              ),
              _UserTaskItem(
                title: 'Draft Workspace Switcher & 2-Step Quickstart Modal',
                project: 'Design Systems',
                status: 'In Progress',
                statusColor: AppColors.skyBlue,
                priority: 'Medium',
                priorityColor: AppColors.priorityMedium,
                dueDate: 'Sep 05',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Section 3: Up Next (Todo) ──
          _buildTaskSection(
            context,
            theme,
            title: '📋 Up Next in Sprint',
            color: AppColors.electricViolet,
            tasks: [
              _UserTaskItem(
                title: 'Integrate PostgreSQL Migration Health Check',
                project: 'Backend API 10',
                status: 'Todo',
                statusColor: AppColors.electricViolet,
                priority: 'Low',
                priorityColor: AppColors.priorityLow,
                dueDate: 'Sep 10',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSection(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required Color color,
    required List<_UserTaskItem> tasks,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${tasks.length}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tasks.map((task) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TaskCardWidget(task: task),
            )),
      ],
    );
  }
}

class _UserTaskItem {
  final String title;
  final String project;
  final String status;
  final Color statusColor;
  final String priority;
  final Color priorityColor;
  final String dueDate;

  _UserTaskItem({
    required this.title,
    required this.project,
    required this.status,
    required this.statusColor,
    required this.priority,
    required this.priorityColor,
    required this.dueDate,
  });
}

class _TaskCardWidget extends StatelessWidget {
  final _UserTaskItem task;

  const _TaskCardWidget({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Checkbox / Status Action
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: task.priorityColor,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 14,
                color: Colors.transparent,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title & Project
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.project,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      task.dueDate,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Priority Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: task.priorityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              task.priority,
              style: TextStyle(
                color: task.priorityColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
