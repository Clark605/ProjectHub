import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:flutter/material.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanScreen extends StatefulWidget {
  final int projectId;
  final ProjectDto? initialProject;

  const KanbanScreen({super.key, required this.projectId, this.initialProject});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  ProjectDto? _project;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _project = widget.initialProject;
    if (_project == null && widget.projectId > 0) {
      _loadProject();
    }
  }

  Future<void> _loadProject() async {
    if (!getIt.isRegistered<ProjectRepository>()) return;
    setState(() => _isLoading = true);
    try {
      final repo = getIt<ProjectRepository>();
      final project = await repo.getProject(widget.projectId);
      if (mounted) {
        setState(() {
          _project = project;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openProjectSettings() async {
    final result = await Navigator.of(
      context,
    ).pushNamed(RouteNames.projectDetail, arguments: widget.projectId);

    if (result == true && mounted) {
      // Project was deleted from details screen, return to projects overview
      Navigator.of(context).pop(true);
    } else if (mounted && widget.projectId > 0) {
      // Reload in case project name/details changed
      _loadProject();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final projectName =
        _project?.name ??
        (_isLoading ? '...' : (l10n?.projectsTitle ?? 'Project'));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              projectName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Kanban Board',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n?.projectDetails ?? 'Project Settings',
            onPressed: _openProjectSettings,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AmbientGlowBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.electricViolet.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.electricViolet.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.view_kanban_outlined,
                  size: 36,
                  color: AppColors.electricViolet,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Kanban Board (Placeholder)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sprint & Kanban Orchestration is coming soon.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
