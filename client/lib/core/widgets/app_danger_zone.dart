import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class AppDangerZone extends StatelessWidget {
  const AppDangerZone({
    super.key,
    required this.title,
    required this.description,
    required this.entityName,
    required this.onDelete,
  });

  final String title;
  final String description;
  final String entityName;
  final VoidCallback onDelete;

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(
        entityName: entityName,
        onConfirm: () {
          Navigator.of(context).pop();
          onDelete();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.error),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _showConfirmationDialog(context),
              child: Text(l10n?.delete ?? 'Delete'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteConfirmationDialog extends StatefulWidget {
  const _DeleteConfirmationDialog({
    required this.entityName,
    required this.onConfirm,
  });

  final String entityName;
  final VoidCallback onConfirm;

  @override
  State<_DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<_DeleteConfirmationDialog> {
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
      title: Text(l10n?.areYouSureDelete ?? 'Are you absolutely sure?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.actionCannotBeUndone ??
                'This action cannot be undone. This will permanently delete the entity.',
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.typeToConfirm(widget.entityName) ??
                'Please type "${widget.entityName}" to confirm.',
          ),
          const SizedBox(height: 8),
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
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          onPressed: _canConfirm ? widget.onConfirm : null,
          child: Text(l10n?.delete ?? 'Delete'),
        ),
      ],
    );
  }
}
