import 'package:flutter/material.dart';
import 'package:client/core/dialog/dialog.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/extensions/context_extensions.dart';

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
    showAppTypeToConfirmDialog(
      context: context,
      entityName: entityName,
      onConfirm: onDelete,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.error),
        borderRadius: AppRadius.kRadiusSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
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
            AppSpacing.gapHSm,
            Text(description),
            AppSpacing.gapHLg,
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.pureWhite,
              ),
              onPressed: () => _showConfirmationDialog(context),
              child: Text(l10n.delete),
            ),
          ],
        ),
      ),
    );
  }
}
