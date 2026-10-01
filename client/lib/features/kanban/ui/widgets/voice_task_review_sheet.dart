import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/features/kanban/ui/widgets/create_task_assignee_due_date_row.dart';
import 'package:client/features/kanban/ui/widgets/create_task_priority_selector.dart';
import 'package:client/features/kanban/ui/widgets/create_task_text_fields.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/parsed_task_draft_dto.dart';
import 'package:client/features/tasks/data/models/task_priority.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';

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

class _VoiceTaskReviewSheetState extends State<VoiceTaskReviewSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late TaskPriority _selectedPriority;
  String? _selectedAssigneeId;
  DateTime? _selectedDueDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.draft.title);
    _descriptionController = TextEditingController(
      text: widget.draft.description,
    );
    _selectedPriority = TaskPriority.fromString(widget.draft.priority);
    _selectedAssigneeId = widget.draft.assigneeId;
    _selectedDueDate = widget.draft.dueDate;
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
      await widget.onSubmit(request, TaskStatus.backlog.toServerString());
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _buildHeader(),
                if (widget.draft.warnings.isNotEmpty) _buildWarningsBanner(),
                const SizedBox(height: 16),
                CreateTaskTextFields(
                  titleController: _titleController,
                  descriptionController: _descriptionController,
                ),
                const SizedBox(height: 18),
                CreateTaskPrioritySelector(
                  selectedPriority: _selectedPriority,
                  onPriorityChanged: (p) =>
                      setState(() => _selectedPriority = p),
                ),
                const SizedBox(height: 18),
                CreateTaskAssigneeDueDateRow(
                  members: widget.members,
                  selectedAssigneeId: _selectedAssigneeId,
                  selectedDueDate: _selectedDueDate,
                  onAssigneeChanged: (val) =>
                      setState(() => _selectedAssigneeId = val),
                  onPickDueDate: _pickDueDate,
                  onClearDueDate: () => setState(() => _selectedDueDate = null),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Confirm & Create Task',
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

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.electricVioletContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.electricVioletContainer),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 14,
                color: AppColors.electricViolet,
              ),
              SizedBox(width: 4),
              Text(
                'AI Draft Preview',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.electricViolet,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildWarningsBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.draft.warnings
            .map(
              (w) => Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      w,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
