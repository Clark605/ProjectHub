import 'package:flutter/material.dart';

import 'package:client/core/dialog/dialog.dart';
import 'package:client/core/errors/app_exception.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/core/widgets/app_error_banner.dart';
import 'package:client/features/kanban/ui/widgets/create_task/create_task_assignee_due_date_row.dart';
import 'package:client/features/kanban/ui/widgets/create_task/create_task_header.dart';
import 'package:client/features/kanban/ui/widgets/create_task/create_task_priority_selector.dart';
import 'package:client/features/kanban/ui/widgets/create_task/create_task_tags_selector.dart';
import 'package:client/features/kanban/ui/widgets/create_task/create_task_text_fields.dart';
import 'package:client/features/kanban/ui/widgets/create_task/task_form_state_mixin.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class CreateTaskSheet extends StatefulWidget {
  final int projectId;
  final String initialStatus;
  final List<MemberDto> members;
  final Future<void> Function(CreateTaskRequest request, String targetStatus)
  onSubmit;

  const CreateTaskSheet({
    super.key,
    required this.projectId,
    this.initialStatus = 'Backlog',
    this.members = const [],
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required int projectId,
    String initialStatus = 'Backlog',
    List<MemberDto> members = const [],
    required Future<void> Function(
      CreateTaskRequest request,
      String targetStatus,
    )
    onSubmit,
  }) {
    return showAppBottomSheet(
      context: context,
      builder: (_) => CreateTaskSheet(
        projectId: projectId,
        initialStatus: initialStatus,
        members: members,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<CreateTaskSheet>
    with TaskFormStateMixin<CreateTaskSheet> {
  late TaskStatus _selectedStatus;
  final List<TagDto> _selectedTags = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    initTaskFormState();
    _selectedStatus = TaskStatus.fromString(widget.initialStatus);
  }

  @override
  void dispose() {
    disposeTaskFormState();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() {
      isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final request = CreateTaskRequest(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        priority: selectedPriority.toServerString(),
        status: _selectedStatus.toServerString(),
        assigneeId: selectedAssigneeId,
        dueDate: selectedDueDate,
        tagIds: _selectedTags.map((t) => t.id).toList(),
      );
      await widget.onSubmit(request, _selectedStatus.toServerString());
      if (mounted) Navigator.of(context).pop();
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          isSubmitting = false;
          _errorMessage = e is AppException
              ? e.message
              : (e.toString().isNotEmpty &&
                    !e.toString().startsWith('Exception:'))
              ? e.toString()
              : context.l10n.somethingWentWrong;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CreateTaskHeader(selectedStatus: _selectedStatus),
              if (_errorMessage != null) ...[
                AppSpacing.gapHSm,
                AppErrorBanner(
                  errorMessage: _errorMessage,
                  onDismiss: () => setState(() => _errorMessage = null),
                ),
              ],
              AppSpacing.gapHMd,
              CreateTaskTextFields(
                titleController: titleController,
                descriptionController: descriptionController,
              ),
              AppSpacing.gapHMd,
              CreateTaskPrioritySelector(
                selectedPriority: selectedPriority,
                onPriorityChanged: (p) => setState(() => selectedPriority = p),
              ),
              AppSpacing.gapHMd,
              CreateTaskAssigneeDueDateRow(
                members: widget.members,
                selectedAssigneeId: selectedAssigneeId,
                selectedDueDate: selectedDueDate,
                onAssigneeChanged: (val) =>
                    setState(() => selectedAssigneeId = val),
                onPickDueDate: () => pickDueDate(context),
                onClearDueDate: clearDueDate,
              ),
              AppSpacing.gapHMd,
              CreateTaskTagsSelector(
                projectId: widget.projectId,
                selectedTags: _selectedTags,
                onTagAdded: (t) => setState(() => _selectedTags.add(t)),
                onTagRemoved: (t) => setState(
                  () => _selectedTags.removeWhere((x) => x.id == t.id),
                ),
              ),
              AppSpacing.gapHLg,
              AppButton(
                label: l10n.createTask,
                isLoading: isSubmitting,
                variant: AppButtonVariant.primary,
                onPressed: isSubmitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
