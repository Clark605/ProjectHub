import 'package:flutter/material.dart';

import 'package:client/core/widgets/app_button.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_priority.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/ui/widgets/task_detail_assignee_due_fields.dart';
import 'package:client/features/tasks/ui/widgets/task_priority_selector.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class TaskDetailEditForm extends StatefulWidget {
  final TaskDto task;
  final List<MemberDto> members;
  final Future<void> Function(UpdateTaskRequest request) onSave;

  const TaskDetailEditForm({
    super.key,
    required this.task,
    required this.members,
    required this.onSave,
  });

  @override
  State<TaskDetailEditForm> createState() => _TaskDetailEditFormState();
}

class _TaskDetailEditFormState extends State<TaskDetailEditForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TaskPriority _editPriority;
  String? _editAssigneeId;
  DateTime? _editDueDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _editPriority = widget.task.priorityEnum;
    _editAssigneeId = widget.task.assigneeId;
    _editDueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _editDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null && mounted) {
      setState(() => _editDueDate = picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final request = UpdateTaskRequest(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _editPriority.toServerString(),
        assigneeId: _editAssigneeId,
        dueDate: _editDueDate,
      );
      await widget.onSave(request);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _titleController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n?.taskTitleRequiredLabel ??
                  (l10n?.taskTitle != null ? '${l10n!.taskTitle} *' : 'Title *'),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            validator: (v) => v == null || v.trim().isEmpty
                ? (l10n?.taskTitleRequired ?? 'Title is required')
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descController,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: l10n?.taskDescription ?? 'Description',
              hintText: l10n?.taskDescriptionPlaceholder,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TaskPrioritySelector(
            selectedPriority: _editPriority,
            onSelected: (p) => setState(() => _editPriority = p),
          ),
          const SizedBox(height: 16),
          TaskDetailAssigneeDueFields(
            members: widget.members,
            editAssigneeId: _editAssigneeId,
            taskAssigneeName: widget.task.assigneeName,
            editDueDate: _editDueDate,
            onAssigneeChanged: (val) => setState(() => _editAssigneeId = val),
            onPickDueDate: _pickDueDate,
            onClearDueDate: () => setState(() => _editDueDate = null),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: l10n?.saveChanges ?? (l10n?.save ?? 'Save Changes'),
            isLoading: _isSaving,
            variant: AppButtonVariant.primary,
            onPressed: _isSaving ? null : _handleSave,
          ),
        ],
      ),
    );
  }
}
