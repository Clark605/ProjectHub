import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/core/widgets/app_text_field.dart';
import 'package:client/core/widgets/app_date_field.dart';
import 'package:client/features/projects/cubit/project_detail_cubit.dart';
import 'package:client/features/projects/cubit/project_detail_state.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/ui/widgets/project_status_dropdown.dart';
import 'package:client/l10n/generated/app_localizations.dart';

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
    _nameController = TextEditingController();
    _descController = TextEditingController();
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
      _selectedStatus = state.project.status.isNotEmpty ? state.project.status : 'Planning';
      _selectedDueDate = state.project.dueDate;
      _lastProjectId = state.project.id;
    }
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<ProjectDetailCubit>();
    final state = cubit.state;
    if (state is ProjectDetailLoaded) {
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocConsumer<ProjectDetailCubit, ProjectDetailState>(
      listener: (context, state) {
        if (state is ProjectDetailLoaded) {
          _syncControllers(state);
        }
      },
      builder: (context, state) {
        if (state is! ProjectDetailLoaded) return const SizedBox.shrink();

        final isSaving = state.isSaving;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
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
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (!widget.canEdit)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Read-only',
                          style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: l10n.projectName,
                  controller: _nameController,
                  enabled: widget.canEdit && !isSaving,
                  validator: (value) =>
                      value?.trim().isEmpty == true ? l10n.projectNameRequired : null,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Description',
                  controller: _descController,
                  enabled: widget.canEdit && !isSaving,
                  maxLines: 4,
                  hintText: 'Description...',
                ),
                const SizedBox(height: 20),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: IgnorePointer(
                        ignoring: !widget.canEdit || isSaving,
                        child: AppDateField(
                          label: l10n.dueDate,
                          selectedDate: _selectedDueDate,
                          onDateSelected: (date) => setState(() => _selectedDueDate = date),
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.canEdit) ...[
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton(
                        label: 'Save',
                        onPressed: _saveChanges,
                        isLoading: isSaving,
                        isExpanded: false,
                        icon: Icons.save_rounded,
                      ),
                    ],
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

