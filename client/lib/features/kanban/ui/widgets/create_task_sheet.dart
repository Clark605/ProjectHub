import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:client/core/widgets/app_button.dart';
import 'package:client/l10n/generated/app_localizations.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_priority.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/tasks/ui/extensions/task_priority_ui.dart';
import 'package:client/features/tasks/ui/extensions/task_status_ui.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';

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
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => CreateTaskSheet(
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

class _CreateTaskSheetState extends State<CreateTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late TaskPriority _selectedPriority;
  late TaskStatus _selectedStatus;
  String? _selectedAssigneeId;
  DateTime? _selectedDueDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedPriority = TaskPriority.medium;
    _selectedStatus = TaskStatus.fromString(widget.initialStatus);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDueDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final request = CreateTaskRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority.toServerString(),
        assigneeId: _selectedAssigneeId,
        dueDate: _selectedDueDate,
      );

      await widget.onSubmit(request, _selectedStatus.toServerString());
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sheet Title
                Row(
                  children: [
                    Text(
                      l10n?.createTask ?? 'Create Task',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedStatus.toColor().withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n != null
                            ? _selectedStatus.localizedName(l10n)
                            : _selectedStatus.toDisplayString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _selectedStatus.toColor(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title Input
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n?.taskTitle ?? 'Task Title *',
                    hintText: l10n?.taskTitlePlaceholder ?? 'What needs to be done?',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return l10n?.taskTitleRequired ?? 'Task title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description Input
                TextFormField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: l10n?.taskDescription ?? 'Description',
                    hintText: l10n?.taskDescriptionPlaceholder ??
                        'Add details, context, or acceptance criteria...',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Priority Selection
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
                    final isSelected = priority == _selectedPriority;
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
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedPriority = priority);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // Assignee & Due Date Row
                Row(
                  children: [
                    // Assignee Dropdown
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.assignee ?? 'Assignee',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String?>(
                            initialValue: _selectedAssigneeId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceContainer,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            hint: Text(l10n?.unassigned ?? 'Unassigned'),
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text(l10n?.unassigned ?? 'Unassigned'),
                              ),
                              if (_selectedAssigneeId != null &&
                                  !widget.members.any(
                                    (m) => m.userId == _selectedAssigneeId,
                                  ))
                                DropdownMenuItem<String?>(
                                  value: _selectedAssigneeId,
                                  child: Text(l10n?.assignedMember ?? 'Assigned Member'),
                                ),
                              ...widget.members.map(
                                (m) => DropdownMenuItem<String?>(
                                  value: m.userId,
                                  child: Text(
                                    m.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (val) =>
                                setState(() => _selectedAssigneeId = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Due Date Button
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
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
                                      _selectedDueDate != null
                                          ? DateFormat(
                                              'MMM d, yyyy',
                                            ).format(_selectedDueDate!)
                                          : (l10n?.noDueDate ?? 'No date'),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: _selectedDueDate != null
                                                ? null
                                                : theme.colorScheme.onSurfaceVariant,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (_selectedDueDate != null)
                                    GestureDetector(
                                      onTap: () => setState(
                                        () => _selectedDueDate = null,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit Button
                AppButton(
                  label: l10n?.createTask ?? 'Create Task',
                  isLoading: _isSubmitting,
                  variant: AppButtonVariant.primary,
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
