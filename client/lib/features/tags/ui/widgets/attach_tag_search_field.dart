import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class AttachTagSearchField extends StatelessWidget {
  const AttachTagSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final border = OutlineInputBorder(
      borderRadius: AppRadius.r10,
      borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
    );

    return TextField(
      controller: controller,
      autofocus: true,
      onChanged: onChanged,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: l10n.searchOrCreateTag,
        hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        prefixIcon: Icon(
          Icons.search,
          size: AppIconSize.md,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerLow,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      ),
    );
  }
}
