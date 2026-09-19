import 'package:flutter/material.dart';

import 'package:client/core/widgets/app_button.dart';
import 'package:client/features/kanban/ui/widgets/create_task_assignee_due_date_row.dart';
import 'package:client/features/kanban/ui/widgets/create_task_header.dart';
import 'package:client/features/kanban/ui/widgets/create_task_priority_selector.dart';
import 'package:client/features/kanban/ui/widgets/create_task_text_fields.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_priority.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class CreateTaskSheet extends StatefulWidget {
  final int projectId;
  final String initialStatus;
  final List<MemberDto> members;
  final Future<void> Function(CreateTaskRequest request, String targetStatus) onSubmit;

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
    required Future<void> Function(CreateTaskRequest request, String targetStatus) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _isSubmitting = false);
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
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CreateTaskHeader(selectedStatus: _selectedStatus),
                const SizedBox(height: 20),
                CreateTaskTextFields(
                  titleController: _titleController,
                  descriptionController: _descriptionController,
                ),
                const SizedBox(height: 18),
                CreateTaskPrioritySelector(
                  selectedPriority: _selectedPriority,
                  onPriorityChanged: (p) => setState(() => _selectedPriority = p),
                ),
                const SizedBox(height: 18),
                CreateTaskAssigneeDueDateRow(
                  members: widget.members,
                  selectedAssigneeId: _selectedAssigneeId,
                  selectedDueDate: _selectedDueDate,
                  onAssigneeChanged: (val) => setState(() => _selectedAssigneeId = val),
                  onPickDueDate: _pickDueDate,
                  onClearDueDate: () => setState(() => _selectedDueDate = null),
                ),
                const SizedBox(height: 24),
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
