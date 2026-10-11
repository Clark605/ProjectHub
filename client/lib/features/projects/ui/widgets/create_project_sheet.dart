import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/dialog/dialog.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/core/widgets/app_text_field.dart';
import 'package:client/core/widgets/app_date_field.dart';
import 'package:client/core/widgets/app_error_banner.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/cubit/projects_list_state.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class CreateProjectSheet extends StatefulWidget {
  final ProjectsListCubit? cubit;

  const CreateProjectSheet({super.key, this.cubit});

  static void show(BuildContext context, {ProjectsListCubit? cubit}) {
    showAppBottomSheet(
      context: context,
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
      if (created != null && context.mounted) {
        Navigator.of(context).pop(created);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cubit = widget.cubit ?? context.read<ProjectsListCubit>();

    return BlocBuilder<ProjectsListCubit, ProjectsListState>(
      bloc: cubit,
      builder: (context, state) {
        final isLoading = state.mapOrNull(loading: (_) => true) ?? false;
        final errorMessage = state.mapOrNull(
          error: (s) => s.failure.toLocalizedMessage(l10n),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.md,
            AppSpacing.xxl,
            AppSpacing.xxl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppSheetDragHandle(),
                AppSpacing.gapH12,
                Text(
                  l10n.newProject,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.gapH4,
                Text(
                  l10n.projectsSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                AppSpacing.gapH20,
                if (errorMessage != null) ...[
                  AppErrorBanner(errorMessage: errorMessage),
                  AppSpacing.gapH16,
                ],
                AppTextField(
                  controller: _nameController,
                  label: l10n.projectName,
                  hintText: l10n.projectNamePlaceholder,
                  prefixIcon: Icons.folder_outlined,
                  enabled: !isLoading,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.projectNameRequired
                      : null,
                ),
                AppSpacing.gapH16,
                AppTextField(
                  controller: _descController,
                  label: l10n.projectDescription,
                  hintText: l10n.projectDescriptionPlaceholder,
                  prefixIcon: Icons.notes_rounded,
                  enabled: !isLoading,
                  maxLines: 3,
                ),
                AppSpacing.gapH16,
                IgnorePointer(
                  ignoring: isLoading,
                  child: AppDateField(
                    label: l10n.dueDate,
                    selectedDate: _selectedDueDate,
                    onDateSelected: (date) =>
                        setState(() => _selectedDueDate = date),
                  ),
                ),
                AppSpacing.gapH24,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(l10n.cancel),
                    ),
                    AppSpacing.gapW12,
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
