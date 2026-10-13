import 'package:client/core/dialog/app_confirm_dialog.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class DeleteTaskDialog extends StatelessWidget {
  const DeleteTaskDialog({super.key, required this.taskTitle});

  final String taskTitle;

  static Future<bool?> show(BuildContext context, String taskTitle) {
    final l10n = context.l10n;
    return showAppConfirmDialog(
      context: context,
      title: l10n.deleteTaskConfirmTitle,
      message: l10n.deleteTaskConfirmMessage(taskTitle),
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppConfirmDialog(
      title: l10n.deleteTaskConfirmTitle,
      message: l10n.deleteTaskConfirmMessage(taskTitle),
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );
  }
}
