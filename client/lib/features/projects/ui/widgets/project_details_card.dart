import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/core/widgets/app_text_field.dart';
import 'package:client/features/projects/cubit/project_detail_cubit.dart';
import 'package:client/features/projects/cubit/project_detail_state.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
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
  late String _selectedStatus;
  DateTime? _selectedDueDate;
  int? _lastProjectId;

  static const List<String> _statuses = [
    'Planning',
    'Active',
    'Completed',
    'Archived',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _selectedStatus = 'Planning';
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

  Future<void> _pickDueDate() async {
    if (!widget.canEdit) return;

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.electricVioletContainer),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDueDate = picked);
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
        _syncControllers(state);

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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!widget.canEdit)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Read-only',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                  ],
                ),
                if (!widget.canEdit) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.noPermissionToEditProject,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                AppTextField(
                  controller: _nameController,
                  label: l10n.projectName,
                  hintText: l10n.projectNamePlaceholder,
                  enabled: widget.canEdit && !isSaving,
                  prefixIcon: Icons.folder_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.projectNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descController,
                  label: l10n.projectDescription,
                  hintText: l10n.projectDescriptionPlaceholder,
                  enabled: widget.canEdit && !isSaving,
                  prefixIcon: Icons.notes_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Status Dropdown
                Text(
                  l10n.projectStatus,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.6),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statuses.contains(_selectedStatus)
                          ? _selectedStatus
                          : 'Planning',
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceContainer,
                      icon: const Icon(Icons.arrow_drop_down_rounded),
                      onChanged: widget.canEdit && !isSaving
                          ? (value) {
                              if (value != null) {
                                setState(() => _selectedStatus = value);
                              }
                            }
                          : null,
                      items: _statuses.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            status,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: widget.canEdit
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Due Date field
                Text(
                  l10n.dueDate,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: widget.canEdit && !isSaving ? _pickDueDate : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedDueDate != null
                                ? DateFormat.yMMMd().format(_selectedDueDate!)
                                : l10n.selectDueDate,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _selectedDueDate != null
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (widget.canEdit && _selectedDueDate != null)
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: isSaving
                                ? null
                                : () => setState(() => _selectedDueDate = null),
                            color: AppColors.textTertiary,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Metadata footer
                if (state.project.createdByName.isNotEmpty ||
                    state.project.createdBy.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(
                        '${l10n.createdBy}: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Text(
                        state.project.createdByName.isNotEmpty
                            ? state.project.createdByName
                            : state.project.createdBy,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                if (widget.canEdit)
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton(
                      label: l10n.save,
                      isLoading: isSaving,
                      isExpanded: false,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<ProjectDetailCubit>().updateProject(
                            UpdateProjectRequest(
                              name: _nameController.text.trim(),
                              description: _descController.text.trim(),
                              status: _selectedStatus,
                              dueDate: _selectedDueDate,
                            ),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
