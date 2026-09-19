import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/ui/widgets/move_to_status_sheet.dart';
import 'package:client/features/tasks/ui/widgets/task_detail_edit_form.dart';
import 'package:client/features/tasks/ui/widgets/task_detail_read_view.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
  late TaskDto _currentTask;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  Future<void> _handleUpdate(UpdateTaskRequest request) async {
    await widget.onUpdate(request);
    final member = widget.members
        .where((m) => m.userId == request.assigneeId)
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
      });
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.deleteTaskConfirmTitle ?? 'Delete Task'),
        content: Text(
          l10n?.deleteTaskConfirmMessage(_currentTask.title) ??
              'Are you sure you want to delete "${_currentTask.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n?.delete ?? 'Delete'),
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
    final l10n = AppLocalizations.of(context);
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
              Row(
                children: [
                  InkWell(
                    onTap: widget.isArchived ? null : _openStatusMove,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _currentTask.statusEnum
                            .toColor()
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _currentTask.statusEnum
                              .toColor()
                              .withValues(alpha: 0.4),
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
                            l10n != null
                                ? _currentTask.statusEnum.localizedName(l10n)
                                : _currentTask.statusEnum.toDisplayString(),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _currentTask.priorityEnum
                          .toColor()
                          .withValues(alpha: 0.15),
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
                          l10n != null
                              ? _currentTask.priorityEnum.localizedName(l10n)
                              : _currentTask.priorityEnum.toDisplayString(),
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
                  if (!_isEditMode) ...[
                    if (!widget.isArchived)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: l10n?.editTask ?? 'Edit Task',
                        onPressed: () => setState(() => _isEditMode = true),
                      ),
                    if (!widget.isArchived)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: AppColors.error,
                        ),
                        tooltip: l10n?.deleteTaskConfirmTitle ?? 'Delete Task',
                        onPressed: _confirmDelete,
                      ),
                  ] else ...[
                    TextButton(
                      onPressed: () => setState(() => _isEditMode = false),
                      child: Text(l10n?.cancel ?? 'Cancel'),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              if (!_isEditMode)
                TaskDetailReadView(task: _currentTask)
              else
                TaskDetailEditForm(
                  task: _currentTask,
                  members: widget.members,
                  onSave: _handleUpdate,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
