import 'package:flutter/material.dart';

import 'package:client/core/utils/date_picker_utils.dart';
import 'package:client/features/tasks/data/models/task_priority.dart';

mixin TaskFormStateMixin<T extends StatefulWidget> on State<T> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  late TaskPriority selectedPriority;
  String? selectedAssigneeId;
  DateTime? selectedDueDate;
  bool isSubmitting = false;

  void initTaskFormState({
    String? title,
    String? description,
    TaskPriority? priority,
    String? assigneeId,
    DateTime? dueDate,
  }) {
    titleController = TextEditingController(text: title ?? '');
    descriptionController = TextEditingController(text: description ?? '');
    selectedPriority = priority ?? TaskPriority.medium;
    selectedAssigneeId = assigneeId;
    selectedDueDate = dueDate;
  }

  void disposeTaskFormState() {
    titleController.dispose();
    descriptionController.dispose();
  }

  Future<void> pickDueDate(BuildContext context) async {
    final picked = await showTaskDatePicker(
      context,
      initialDate: selectedDueDate,
    );
    if (picked != null && mounted) {
      setState(() => selectedDueDate = picked);
    }
  }

  void clearDueDate() {
    setState(() => selectedDueDate = null);
  }
}
