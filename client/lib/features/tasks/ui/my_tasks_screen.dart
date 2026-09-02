import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/features/tasks/ui/widgets/task_card_widget.dart';
import 'package:client/features/tasks/ui/widgets/task_section_widget.dart';
import 'package:client/features/tasks/ui/widgets/tasks_tab_switcher.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  String _activeTab = 'Assigned to Me';
  final List<String> _tabs = ['Assigned to Me', 'Created by Me', 'Completed'];

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
              ),
              const SizedBox(width: 16),
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
          TasksTabSwitcher(
            activeTab: _activeTab,
            tabs: _tabs,
            onTabSelected: (tab) => setState(() => _activeTab = tab),
          ),
          const SizedBox(height: 24),

          // ── Section 1: Urgent & Blocker Items ──
          const TaskSectionWidget(
            title: '🚨 Urgent & High Priority',
            color: AppColors.priorityUrgent,
            tasks: [
              UserTaskItem(
                title: 'Implement Refresh Token Queue Interceptor',
                project: 'Mobile Client v1',
                status: 'In Progress',
                statusColor: AppColors.skyBlue,
                priority: 'Urgent',
                priorityColor: AppColors.priorityUrgent,
                dueDate: 'Due Today',
              ),
              UserTaskItem(
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
          const TaskSectionWidget(
            title: '⚡ In Progress',
            color: AppColors.skyBlue,
            tasks: [
              UserTaskItem(
                title: 'Build Responsive Shell with Fixed 240px Sidebar',
                project: 'Mobile Client v1',
                status: 'In Progress',
                statusColor: AppColors.skyBlue,
                priority: 'Medium',
                priorityColor: AppColors.priorityMedium,
                dueDate: 'Sep 04',
              ),
              UserTaskItem(
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
          const TaskSectionWidget(
            title: '📋 Up Next in Sprint',
            color: AppColors.electricViolet,
            tasks: [
              UserTaskItem(
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
}
