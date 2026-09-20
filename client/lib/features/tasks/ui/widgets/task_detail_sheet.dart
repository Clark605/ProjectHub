import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
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
      builder: (_) => TaskDetailSheet(
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
    final member = widget.members.where((m) => m.userId == request.assigneeId).firstOrNull;

    if (mounted) {
      setState(() {
        _currentTask = _currentTask.copyWith(
          title: request.title,
          description: request.description,
          priority: request.priority,
          assigneeId: request.assigneeId,
          assigneeName: request.assigneeId == null ? null : (member?.name ?? _currentTask.assigneeName),
          dueDate: request.dueDate,
          updatedAt: DateTime.now(),
        );
        _isEditMode = false;
      });
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
      onStatusSelected: (newStatus) async {
        await widget.onStatusChange(newStatus.toServerString());
        if (mounted) {
          setState(() => _currentTask = _currentTask.copyWith(status: newStatus.toServerString()));
        }
      },
    );
  }

  Future<void> _onTagAdded(TagDto tag) async {
    try {
      final updated = await getIt<TagRepository>().attachTagToTask(_currentTask.id, tag.id);
      if (mounted) setState(() => _currentTask = updated);
    } catch (_) {}
  }

  Future<void> _onTagRemoved(TagDto tag) async {
    try {
      final updated = await getIt<TagRepository>().detachTagFromTask(_currentTask.id, tag.id);
      if (mounted) setState(() => _currentTask = updated);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    AppAuthState? authState;
    try {
      authState = context.read<AppAuthCubit>().state;
    } catch (_) {
      if (getIt.isRegistered<AppAuthCubit>()) {
        authState = getIt<AppAuthCubit>().state;
      }
    }
    final authUser = authState?.mapOrNull(authenticated: (a) => a.user);
    final currentUserId = authUser?.id ?? '';
    final isWorkspaceOwner = widget.members.any((m) => m.userId == currentUserId && m.role == 'Owner');

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
                  currentUserId: currentUserId,
                  isWorkspaceOwner: isWorkspaceOwner,
                  onTagAdded: _onTagAdded,
                  onTagRemoved: _onTagRemoved,
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
