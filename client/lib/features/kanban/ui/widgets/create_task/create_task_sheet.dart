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
import 'package:client/l10n/generated/app_localizations.dart';

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
    } catch (e) {
      if (mounted) {
        setState(() {
          isSubmitting = false;
          _errorMessage = e is AppException
              ? e.message
              : (e.toString().isNotEmpty &&
                    !e.toString().startsWith('Exception:'))
              ? e.toString()
              : (AppLocalizations.of(context)?.somethingWentWrong ??
                    'Failed to create task');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CreateTaskHeader(selectedStatus: _selectedStatus),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                AppErrorBanner(
                  errorMessage: _errorMessage,
                  onDismiss: () => setState(() => _errorMessage = null),
                ),
              ],
              const SizedBox(height: 14),
              CreateTaskTextFields(
                titleController: titleController,
                descriptionController: descriptionController,
              ),
              const SizedBox(height: 12),
              CreateTaskPrioritySelector(
                selectedPriority: selectedPriority,
                onPriorityChanged: (p) => setState(() => selectedPriority = p),
              ),
              const SizedBox(height: 12),
              CreateTaskAssigneeDueDateRow(
                members: widget.members,
                selectedAssigneeId: selectedAssigneeId,
                selectedDueDate: selectedDueDate,
                onAssigneeChanged: (val) =>
                    setState(() => selectedAssigneeId = val),
                onPickDueDate: () => pickDueDate(context),
                onClearDueDate: clearDueDate,
              ),
              const SizedBox(height: 12),
              CreateTaskTagsSelector(
                projectId: widget.projectId,
                selectedTags: _selectedTags,
                onTagAdded: (t) => setState(() => _selectedTags.add(t)),
                onTagRemoved: (t) => setState(
                  () => _selectedTags.removeWhere((x) => x.id == t.id),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: l10n?.createTask ?? 'Create Task',
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
