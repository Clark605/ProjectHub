import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class KanbanSearchInputRow extends StatelessWidget {
  const KanbanSearchInputRow({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppRadius.r10,
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: true,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: l10n.taskTitlePlaceholder,
                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.s10,
                ),
              ),
            ),
          ),
        ),
        AppSpacing.gapW8,
        IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: l10n.closeSearch,
          onPressed: onClose,
        ),
      ],
    );
  }
}
