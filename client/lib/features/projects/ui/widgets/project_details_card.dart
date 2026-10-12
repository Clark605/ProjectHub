import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/widgets/app_button.dart';
import 'package:client/core/widgets/app_text_field.dart';
import 'package:client/core/widgets/app_date_field.dart';
import 'package:client/features/projects/cubit/project_detail_cubit.dart';
import 'package:client/features/projects/cubit/project_detail_state.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/ui/widgets/project_status_dropdown.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class ProjectDetailsCard extends StatefulWidget {
  final bool canEdit;

  const ProjectDetailsCard({super.key, required this.canEdit});

  @override
  State<ProjectDetailsCard> createState() => _ProjectDetailsCardState();
}

class _ProjectDetailsCardState extends State<ProjectDetailsCard> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  String _selectedStatus = 'Planning';
  DateTime? _selectedDueDate;
  int? _lastProjectId;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProjectDetailCubit>().state.whenOrNull(
      loaded: (project, _, _, _, _) => project,
    );
    _nameController = TextEditingController(text: p?.name ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _selectedDueDate = p?.dueDate;
    _selectedStatus = p?.status ?? 'Planning';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _syncControllers(ProjectDetailLoaded state) {
    if (_lastProjectId != state.project.id) {
      _nameController.text = state.project.name;
      _descController.text = state.project.description;
      _selectedStatus = state.project.status.isNotEmpty
          ? state.project.status
          : 'Planning';
      _selectedDueDate = state.project.dueDate;
      _lastProjectId = state.project.id;
    }
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<ProjectDetailCubit>();
    if (cubit.state is ProjectDetailLoaded) {
      cubit.updateProject(
        UpdateProjectRequest(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          status: _selectedStatus,
          dueDate: _selectedDueDate,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocConsumer<ProjectDetailCubit, ProjectDetailState>(
      listener: (context, state) {
        if (state is ProjectDetailLoaded) _syncControllers(state);
      },
      builder: (context, state) {
        if (state is! ProjectDetailLoaded) return const SizedBox.shrink();
        final isSaving = state.isSaving;

        return Container(
          padding: AppSpacing.edgeInsetsAllXl,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: AppRadius.r16,
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.projectDetails,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!widget.canEdit)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainer,
                          borderRadius: AppRadius.r8,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: Text(
                          l10n.readOnlyBadge,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
                AppSpacing.gapHXxl,
                AppTextField(
                  label: l10n.projectName,
                  controller: _nameController,
                  enabled: widget.canEdit && !isSaving,
                  validator: (value) => value?.trim().isEmpty == true
                      ? l10n.projectNameRequired
                      : null,
                ),
                AppSpacing.gapHXl,
                AppTextField(
                  label: l10n.projectDescription,
                  controller: _descController,
                  enabled: widget.canEdit && !isSaving,
                  maxLines: 4,
                  hintText: l10n.projectDescriptionPlaceholder,
                ),
                AppSpacing.gapHXl,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ProjectStatusDropdown(
                        value: _selectedStatus,
                        enabled: widget.canEdit && !isSaving,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedStatus = val);
                          }
                        },
                      ),
                    ),
                    AppSpacing.gapWLg,
                    Expanded(
                      child: IgnorePointer(
                        ignoring: !widget.canEdit || isSaving,
                        child: AppDateField(
                          label: l10n.dueDate,
                          selectedDate: _selectedDueDate,
                          onDateSelected: (date) =>
                              setState(() => _selectedDueDate = date),
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.canEdit) ...[
                  AppSpacing.gapHXxxl,
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton(
                      label: l10n.save,
                      onPressed: _saveChanges,
                      isLoading: isSaving,
                      isExpanded: false,
                      icon: Icons.save_rounded,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
