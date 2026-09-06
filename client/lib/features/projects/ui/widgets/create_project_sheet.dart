import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/utils/responsive_layout.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/core/widgets/app_text_field.dart';
import 'package:client/core/widgets/app_date_field.dart';
import 'package:client/core/widgets/app_error_banner.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/cubit/projects_list_state.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class CreateProjectSheet extends StatefulWidget {
  final ProjectsListCubit? cubit;

  const CreateProjectSheet({super.key, this.cubit});

  static void show(BuildContext context, {ProjectsListCubit? cubit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateProjectSheet(cubit: cubit),
    );
  }

  @override
  State<CreateProjectSheet> createState() => _CreateProjectSheetState();
}

class _CreateProjectSheetState extends State<CreateProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDueDate;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    
    final request = CreateProjectRequest(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      dueDate: _selectedDueDate,
    );

    final cubit = widget.cubit ?? context.read<ProjectsListCubit>();
    cubit.createProject(request).then((created) {
      if (created != null && mounted) {
        Navigator.of(context).pop(created);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final cubit = widget.cubit ?? context.read<ProjectsListCubit>();

    return BlocBuilder<ProjectsListCubit, ProjectsListState>(
      bloc: cubit,
      builder: (context, state) {
        final isLoading = state.mapOrNull(loading: (_) => true) ?? false;
        final errorMessage = state.mapOrNull(error: (s) => s.message);

        return Container(
          width: isDesktop ? 600 : double.infinity,
          margin: isDesktop ? const EdgeInsets.all(24) : EdgeInsets.zero,
          padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: isDesktop
                ? BorderRadius.circular(24)
                : const BorderRadius.vertical(top: Radius.circular(24)),
            border: isDesktop ? Border.all(color: AppColors.border) : null,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.newProject,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.projectsSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                if (errorMessage != null) ...[
                  AppErrorBanner(errorMessage: errorMessage),
                  const SizedBox(height: 16),
                ],
                AppTextField(
                  controller: _nameController,
                  label: l10n.projectName,
                  hintText: l10n.projectNamePlaceholder,
                  prefixIcon: Icons.folder_outlined,
                  enabled: !isLoading,
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? l10n.projectNameRequired : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descController,
                  label: 'Description',
                  hintText: 'Description...',
                  prefixIcon: Icons.notes_rounded,
                  enabled: !isLoading,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                IgnorePointer(
                  ignoring: isLoading,
                  child: AppDateField(
                    label: l10n.dueDate,
                    selectedDate: _selectedDueDate,
                    onDateSelected: (date) => setState(() => _selectedDueDate = date),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 12),
                    AppButton(
                      label: l10n.createProject,
                      isLoading: isLoading,
                      isExpanded: false,
                      onPressed: () => _submit(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
