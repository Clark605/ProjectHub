import 'package:flutter/material.dart';

import 'package:client/core/widgets/app_button.dart';
import 'package:client/features/kanban/ui/widgets/create_task/create_task_assignee_due_date_row.dart';
import 'package:client/features/kanban/ui/widgets/create_task/create_task_priority_selector.dart';
import 'package:client/features/kanban/ui/widgets/create_task/create_task_text_fields.dart';
import 'package:client/features/kanban/ui/widgets/create_task/task_form_state_mixin.dart';
import 'package:client/features/kanban/ui/widgets/voice/voice_task_review_header.dart';
import 'package:client/features/kanban/ui/widgets/voice/voice_task_review_warnings.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/parsed_task_draft_dto.dart';
import 'package:client/features/tasks/data/models/task_priority.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class VoiceTaskReviewSheet extends StatefulWidget {
  final int projectId;
  final ParsedTaskDraftDto draft;
  final List<MemberDto> members;
  final Future<void> Function(CreateTaskRequest request, String targetStatus)
  onSubmit;

  const VoiceTaskReviewSheet({
    super.key,
    required this.projectId,
    required this.draft,
    this.members = const [],
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required int projectId,
    required ParsedTaskDraftDto draft,
    List<MemberDto> members = const [],
    required Future<void> Function(
      CreateTaskRequest request,
      String targetStatus,
    )
    onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => VoiceTaskReviewSheet(
        projectId: projectId,
        draft: draft,
        members: members,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<VoiceTaskReviewSheet> createState() => _VoiceTaskReviewSheetState();
}

class _VoiceTaskReviewSheetState extends State<VoiceTaskReviewSheet>
    with TaskFormStateMixin<VoiceTaskReviewSheet> {
  @override
  void initState() {
    super.initState();
    initTaskFormState(
      title: widget.draft.title,
      description: widget.draft.description,
      priority: TaskPriority.fromString(widget.draft.priority),
      assigneeId: widget.draft.assigneeId,
      dueDate: widget.draft.dueDate,
    );
  }

  @override
  void dispose() {
    disposeTaskFormState();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isSubmitting = true);
    try {
      final request = CreateTaskRequest(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        priority: selectedPriority.toServerString(),
        assigneeId: selectedAssigneeId,
        dueDate: selectedDueDate,
      );
      await widget.onSubmit(request, TaskStatus.backlog.toServerString());
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                VoiceTaskReviewHeader(
                  onClose: () => Navigator.of(context).pop(),
                ),
                VoiceTaskReviewWarnings(warnings: widget.draft.warnings),
                const SizedBox(height: 16),
                CreateTaskTextFields(
                  titleController: titleController,
                  descriptionController: descriptionController,
                ),
                const SizedBox(height: 18),
                CreateTaskPrioritySelector(
                  selectedPriority: selectedPriority,
                  onPriorityChanged: (p) =>
                      setState(() => selectedPriority = p),
                ),
                const SizedBox(height: 18),
                CreateTaskAssigneeDueDateRow(
                  members: widget.members,
                  selectedAssigneeId: selectedAssigneeId,
                  selectedDueDate: selectedDueDate,
                  onAssigneeChanged: (val) =>
                      setState(() => selectedAssigneeId = val),
                  onPickDueDate: () => pickDueDate(context),
                  onClearDueDate: clearDueDate,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label:
                      l10n?.voiceTaskConfirmCreate ?? 'Confirm & Create Task',
                  isLoading: isSubmitting,
                  variant: AppButtonVariant.primary,
                  onPressed: isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
