import 'package:flutter/material.dart';

import 'package:client/core/dialog/app_confirm_dialog.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class DeleteTaskDialog extends StatelessWidget {
  const DeleteTaskDialog({super.key, required this.taskTitle});

  final String taskTitle;

  static Future<bool?> show(BuildContext context, String taskTitle) {
    final l10n = AppLocalizations.of(context);
    return showAppConfirmDialog(
      context: context,
      title: l10n?.deleteTaskConfirmTitle ?? 'Delete Task',
      message: l10n?.deleteTaskConfirmMessage(taskTitle) ??
          'Are you sure you want to delete "$taskTitle"? This action cannot be undone.',
      confirmLabel: l10n?.delete ?? 'Delete',
      cancelLabel: l10n?.cancel ?? 'Cancel',
      isDestructive: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppConfirmDialog(
      title: l10n?.deleteTaskConfirmTitle ?? 'Delete Task',
      message: l10n?.deleteTaskConfirmMessage(taskTitle) ??
          'Are you sure you want to delete "$taskTitle"? This action cannot be undone.',
      confirmLabel: l10n?.delete ?? 'Delete',
      cancelLabel: l10n?.cancel ?? 'Cancel',
      isDestructive: true,
    );
  }
}
