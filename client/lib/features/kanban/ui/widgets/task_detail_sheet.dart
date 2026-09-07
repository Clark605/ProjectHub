import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/kanban/ui/widgets/move_to_status_sheet.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_priority.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';

class TaskDetailSheet extends StatefulWidget {
  final TaskDto task;
  final bool isArchived;
  final List<MemberDto> members;
  final Future<void> Function(UpdateTaskRequest request) onUpdate;
  final Future<void> Function(String newStatus) onStatusChange;
  final Future<void> Function() onDelete;

  const TaskDetailSheet({
    super.key,
    required this.task,
    this.isArchived = false,
    this.members = const [],
    required this.onUpdate,
    required this.onStatusChange,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required TaskDto task,
    bool isArchived = false,
    List<MemberDto> members = const [],
    required Future<void> Function(UpdateTaskRequest request) onUpdate,
    required Future<void> Function(String newStatus) onStatusChange,
    required Future<void> Function() onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => TaskDetailSheet(
        task: task,
        isArchived: isArchived,
        members: members,
        onUpdate: onUpdate,
        onStatusChange: onStatusChange,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  bool _isEditMode = false;
  bool _isSaving = false;
  late TaskDto _currentTask;

  // Edit mode controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TaskPriority _editPriority;
  String? _editAssigneeId;
  DateTime? _editDueDate;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _initControllers();
  }

  void _initControllers() {
    _titleController = TextEditingController(text: _currentTask.title);
    _descController = TextEditingController(text: _currentTask.description);
    _editPriority = _currentTask.priorityEnum;
    _editAssigneeId = _currentTask.assigneeId;
    _editDueDate = _currentTask.dueDate;
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

  Future<void> _saveChanges() async {
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

      await widget.onUpdate(request);

      final member = widget.members
          .where((m) => m.userId == _editAssigneeId)
          .firstOrNull;

      if (mounted) {
        setState(() {
          _currentTask = _currentTask.copyWith(
            title: request.title,
            description: request.description,
            priority: request.priority,
            assigneeId: request.assigneeId,
            assigneeName: request.assigneeId == null
                ? null
                : (member?.name ?? _currentTask.assigneeName),
            dueDate: request.dueDate,
            updatedAt: DateTime.now(),
          );
          _isEditMode = false;
          _isSaving = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete "${_currentTask.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await widget.onDelete();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _openStatusMove() async {
    if (widget.isArchived) return;

    await MoveToStatusSheet.show(
      context,
      task: _currentTask,
      onStatusSelected: (newStatus) async {
        await widget.onStatusChange(newStatus.toServerString());
        if (mounted) {
          setState(() {
            _currentTask = _currentTask.copyWith(
              status: newStatus.toServerString(),
            );
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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

              // Header actions
              Row(
                children: [
                  // Status badge (tappable to move)
                  InkWell(
                    onTap: widget.isArchived ? null : _openStatusMove,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _currentTask.statusEnum.toColor().withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _currentTask.statusEnum.toColor().withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _currentTask.statusEnum.toIcon(),
                            size: 14,
                            color: _currentTask.statusEnum.toColor(),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _currentTask.statusEnum.toDisplayString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _currentTask.statusEnum.toColor(),
                            ),
                          ),
                          if (!widget.isArchived) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 16,
                              color: _currentTask.statusEnum.toColor(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Priority badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _currentTask.priorityEnum.toColor().withValues(
                        alpha: 0.15,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _currentTask.priorityEnum.toIcon(),
                          size: 14,
                          color: _currentTask.priorityEnum.toColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _currentTask.priorityEnum.toDisplayString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _currentTask.priorityEnum.toColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Edit / Delete buttons
                  if (!_isEditMode) ...[
                    if (!widget.isArchived)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: 'Edit Task',
                        onPressed: () {
                          _initControllers();
                          setState(() => _isEditMode = true);
                        },
                      ),
                    if (!widget.isArchived)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: AppColors.error,
                        ),
                        tooltip: 'Delete Task',
                        onPressed: _confirmDelete,
                      ),
                  ] else ...[
                    TextButton(
                      onPressed: () => setState(() => _isEditMode = false),
                      child: const Text('Cancel'),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Body: Read Mode or Edit Mode
              if (!_isEditMode)
                _buildReadMode(context)
              else
                _buildEditMode(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadMode(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOverdue = _currentTask.isOverdue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          _currentTask.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          _currentTask.description.isNotEmpty
              ? _currentTask.description
              : 'No description provided.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: _currentTask.description.isNotEmpty
                ? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)
                : (isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary),
            fontStyle: _currentTask.description.isEmpty
                ? FontStyle.italic
                : FontStyle.normal,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 16),

        // Metadata grid / tiles
        // Assignee
        _buildInfoRow(
          context,
          icon: Icons.person_outline_rounded,
          label: 'Assignee',
          value: _currentTask.assigneeName ?? 'Unassigned',
        ),
        const SizedBox(height: 12),

        // Due Date
        _buildInfoRow(
          context,
          icon: Icons.calendar_today_outlined,
          label: 'Due Date',
          value: _currentTask.dueDate != null
              ? DateFormat('MMMM d, yyyy').format(_currentTask.dueDate!)
              : 'Not set',
          valueColor: isOverdue ? AppColors.error : null,
          trailing: isOverdue
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Overdue',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),

        // Created By
        _buildInfoRow(
          context,
          icon: Icons.history_edu_rounded,
          label: 'Created By',
          value: _currentTask.createdByName.isNotEmpty
              ? _currentTask.createdByName
              : 'Unknown',
        ),
        const SizedBox(height: 12),

        // Created Date
        if (_currentTask.createdAt != null)
          _buildInfoRow(
            context,
            icon: Icons.access_time_rounded,
            label: 'Created',
            value: DateFormat(
              'MMM d, yyyy • h:mm a',
            ).format(_currentTask.createdAt!.toLocal()),
          ),
      ],
    );
  }

  Widget _buildEditMode(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title Input
          TextFormField(
            controller: _titleController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Title *',
              filled: true,
              fillColor: isDark
                  ? AppColors.surfaceContainer
                  : AppColors.lightSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Title is required' : null,
          ),
          const SizedBox(height: 16),

          // Description Input
          TextFormField(
            controller: _descController,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Description',
              filled: true,
              fillColor: isDark
                  ? AppColors.surfaceContainer
                  : AppColors.lightSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Priority selector
          Text(
            'Priority',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.lightTextSecondary,
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
                label: Text(priority.toDisplayString()),
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

          // Assignee Dropdown
          Text(
            'Assignee',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            initialValue: _editAssigneeId,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark
                  ? AppColors.surfaceContainer
                  : AppColors.lightSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            hint: const Text('Unassigned'),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Unassigned'),
              ),
              if (_editAssigneeId != null &&
                  !widget.members.any((m) => m.userId == _editAssigneeId))
                DropdownMenuItem<String?>(
                  value: _editAssigneeId,
                  child: Text(_currentTask.assigneeName ?? 'Assigned Member'),
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

          // Due Date Picker
          Text(
            'Due Date',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.lightTextSecondary,
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
                color: isDark
                    ? AppColors.surfaceContainer
                    : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.border : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _editDueDate != null
                          ? DateFormat('MMM d, yyyy').format(_editDueDate!)
                          : 'No due date',
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

          // Save Button
          ElevatedButton(
            onPressed: _isSaving ? null : _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricViolet,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark
              ? AppColors.textSecondary
              : AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark
                ? AppColors.textSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ],
    );
  }
}
