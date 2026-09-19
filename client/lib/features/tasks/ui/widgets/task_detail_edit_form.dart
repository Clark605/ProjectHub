import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:client/core/widgets/app_button.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_priority.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
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
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
          Text(
            l10n?.taskPriority ?? 'Priority',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: TaskPriority.values.map((priority) {
              final isSelected = priority == _editPriority;
              return ChoiceChip(
                selected: isSelected,
                avatar: Icon(
                  priority.toIcon(),
                  size: 16,
                  color: isSelected ? Colors.white : priority.toColor(),
                ),
                label: Text(
                  l10n != null
                      ? priority.localizedName(l10n)
                      : priority.toDisplayString(),
                ),
                selectedColor: priority.toColor(),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _editPriority = priority);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.assignee ?? 'Assignee',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            initialValue: _editAssigneeId,
            isExpanded: true,
            decoration: InputDecoration(
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
            hint: Text(l10n?.unassigned ?? 'Unassigned'),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(l10n?.unassigned ?? 'Unassigned'),
              ),
              if (_editAssigneeId != null &&
                  !widget.members.any((m) => m.userId == _editAssigneeId))
                DropdownMenuItem<String?>(
                  value: _editAssigneeId,
                  child: Text(
                    widget.task.assigneeName ??
                        (l10n?.assignedMember ?? 'Assigned Member'),
                  ),
                ),
              ...widget.members.map(
                (m) => DropdownMenuItem<String?>(
                  value: m.userId,
                  child: Text(m.name),
                ),
              ),
            ],
            onChanged: (val) => setState(() => _editAssigneeId = val),
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.dueDate ?? 'Due Date',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDueDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _editDueDate != null
                          ? DateFormat('MMM d, yyyy').format(_editDueDate!)
                          : (l10n?.noDueDate ?? 'No due date'),
                    ),
                  ),
                  if (_editDueDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _editDueDate = null),
                      child: const Icon(Icons.close_rounded, size: 16),
                    ),
                ],
              ),
            ),
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
