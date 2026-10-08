import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
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
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final fillColor = isDark
        ? AppColors.surfaceContainer
        : AppColors.lightSurfaceContainer;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: titleController,
          autofocus: true,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.taskTitle,
            hintText: l10n.taskTitlePlaceholder,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: AppRadius.r12,
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.r12,
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppRadius.r12,
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          validator: (val) => (val == null || val.trim().isEmpty)
              ? (l10n.taskTitleRequired)
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.taskDescription,
            hintText: l10n.taskDescriptionPlaceholder,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: AppRadius.r12,
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.r12,
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppRadius.r12,
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
