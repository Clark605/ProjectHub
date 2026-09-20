import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class DeleteTaskDialog extends StatelessWidget {
  const DeleteTaskDialog({super.key, required this.taskTitle});

  final String taskTitle;

  static Future<bool?> show(BuildContext context, String taskTitle) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => DeleteTaskDialog(taskTitle: taskTitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n?.deleteTaskConfirmTitle ?? 'Delete Task'),
      content: Text(
        l10n?.deleteTaskConfirmMessage(taskTitle) ??
            'Are you sure you want to delete "$taskTitle"? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n?.delete ?? 'Delete'),
        ),
      ],
    );
  }
}
