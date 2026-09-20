import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/tags/data/tag_repository.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/ui/widgets/delete_task_dialog.dart';
import 'package:client/features/tasks/ui/widgets/move_to_status_sheet.dart';
import 'package:client/features/tasks/ui/widgets/task_detail_edit_form.dart';
import 'package:client/features/tasks/ui/widgets/task_detail_header.dart';
import 'package:client/features/tasks/ui/widgets/task_detail_read_view.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';

class TaskDetailSheet extends StatefulWidget {
  final TaskDto task;
  final bool isArchived;
  final List<MemberDto> members;
  final Future<void> Function(UpdateTaskRequest request) onUpdate;
  final Future<void> Function(String newStatus) onStatusChange;
  final Future<void> Function() onDelete;
  final ValueChanged<TaskDto>? onTaskUpdated;

  const TaskDetailSheet({
    super.key,
    required this.task,
    this.isArchived = false,
    this.members = const [],
    required this.onUpdate,
    required this.onStatusChange,
    required this.onDelete,
    this.onTaskUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required TaskDto task,
    bool isArchived = false,
    List<MemberDto> members = const [],
    required Future<void> Function(UpdateTaskRequest) onUpdate,
    required Future<void> Function(String) onStatusChange,
    required Future<void> Function() onDelete,
    ValueChanged<TaskDto>? onTaskUpdated,
  }) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => TaskDetailSheet(
      task: task, isArchived: isArchived, members: members,
      onUpdate: onUpdate, onStatusChange: onStatusChange, onDelete: onDelete,
      onTaskUpdated: onTaskUpdated,
    ),
  );

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

  Future<void> _handleUpdate(UpdateTaskRequest req) async {
    await widget.onUpdate(req);
    final m = widget.members
        .where((x) => x.userId == req.assigneeId)
        .firstOrNull;
    if (mounted) {
      final u = _currentTask.copyWith(
        title: req.title,
        description: req.description,
        priority: req.priority,
        assigneeId: req.assigneeId,
        assigneeName: req.assigneeId == null
            ? null
            : (m?.name ?? _currentTask.assigneeName),
        dueDate: req.dueDate,
        updatedAt: DateTime.now(),
      );
      setState(() {
        _currentTask = u;
        _isEditMode = false;
      });
      widget.onTaskUpdated?.call(u);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await DeleteTaskDialog.show(context, _currentTask.title);
    if (confirmed == true && mounted) {
      await widget.onDelete();
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _openStatusMove() async {
    if (widget.isArchived) return;
    await MoveToStatusSheet.show(
      context,
      task: _currentTask,
      onStatusSelected: (s) async {
        await widget.onStatusChange(s.toServerString());
        if (mounted) {
          final u = _currentTask.copyWith(status: s.toServerString());
          setState(() => _currentTask = u);
          widget.onTaskUpdated?.call(u);
        }
      },
    );
  }

  Future<void> _mutateTag(Future<TaskDto> Function() mutate) async {
    try {
      final u = await mutate();
      if (mounted) {
        setState(() => _currentTask = u);
        widget.onTaskUpdated?.call(u);
      }
    } catch (_) {}
  }

  TagRepository? get _tagRepo =>
      getIt.isRegistered<TagRepository>() ? getIt<TagRepository>() : null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.read<AppAuthCubit?>()?.state ??
        (getIt.isRegistered<AppAuthCubit>() ? getIt<AppAuthCubit>().state : null);
    final uid = auth != null ? (auth.whenOrNull(authenticated: (u) => u.id) ?? '') : '';
    final isOwner = widget.members.any((m) => m.userId == uid && m.role == 'Owner');

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              TaskDetailHeader(
                task: _currentTask,
                isArchived: widget.isArchived,
                isEditMode: _isEditMode,
                onOpenStatusMove: _openStatusMove,
                onStartEdit: () => setState(() => _isEditMode = true),
                onCancelEdit: () => setState(() => _isEditMode = false),
                onDelete: _confirmDelete,
              ),
              const SizedBox(height: 16),
              if (!_isEditMode)
                TaskDetailReadView(
                  task: _currentTask,
                  isArchived: widget.isArchived,
                  currentUserId: uid,
                  isWorkspaceOwner: isOwner,
                  onTagAdded: (t) => _mutateTag(
                    () => _tagRepo?.attachTagToTask(_currentTask.id, t.id) ?? Future.value(_currentTask),
                  ),
                  onTagRemoved: (t) => _mutateTag(
                    () => _tagRepo?.detachTagFromTask(_currentTask.id, t.id) ?? Future.value(_currentTask),
                  ),
                )
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
