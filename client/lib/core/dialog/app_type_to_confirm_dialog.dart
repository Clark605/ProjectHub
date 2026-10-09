import 'package:flutter/material.dart';
import 'package:client/core/dialog/app_dialog.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/l10n/generated/app_localizations.dart';

/// Shows a dialog requiring the user to type the entity name to confirm deletion.
Future<bool> showAppTypeToConfirmDialog({
  required BuildContext context,
  required String entityName,
  VoidCallback? onConfirm,
}) async {
  final result = await showAppDialog<bool>(
    context: context,
    builder: (ctx) => AppTypeToConfirmDialog(
      entityName: entityName,
      onConfirm: () {
        if (onConfirm != null) {
          onConfirm();
        } else {
          Navigator.of(ctx).pop(true);
        }
      },
    ),
  );
  return result ?? false;
}

class AppTypeToConfirmDialog extends StatefulWidget {
  const AppTypeToConfirmDialog({
    super.key,
    required this.entityName,
    required this.onConfirm,
  });

  final String entityName;
  final VoidCallback onConfirm;

  @override
  State<AppTypeToConfirmDialog> createState() => _AppTypeToConfirmDialogState();
}

class _AppTypeToConfirmDialogState extends State<AppTypeToConfirmDialog> {
  late final TextEditingController _controller;
  bool _canConfirm = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {
        _canConfirm = _controller.text == widget.entityName;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.kRadiusLg),
      title: Text(l10n.areYouSureDelete),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.actionCannotBeUndone),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.typeToConfirm(widget.entityName)),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.kRadiusSm,
            ),
          ),
          onPressed: _canConfirm ? widget.onConfirm : null,
          child: Text(l10n.delete),
        ),
      ],
    );
  }
}
