import 'package:flutter/material.dart';

import 'package:client/l10n/generated/app_localizations.dart';

class CreateTaskTextFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const CreateTaskTextFields({
    super.key,
    required this.titleController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: titleController,
          autofocus: true,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n?.taskTitle ?? 'Task Title *',
            hintText: l10n?.taskTitlePlaceholder ?? 'What needs to be done?',
            filled: true,
            fillColor: theme.colorScheme.surfaceContainer,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (val) => (val == null || val.trim().isEmpty)
              ? (l10n?.taskTitleRequired ?? 'Task title is required')
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: l10n?.taskDescription ?? 'Description',
            hintText:
                l10n?.taskDescriptionPlaceholder ??
                'Add details, context, or acceptance criteria...',
            filled: true,
            fillColor: theme.colorScheme.surfaceContainer,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
