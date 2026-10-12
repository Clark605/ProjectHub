import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tags/ui/widgets/attach_tag_modal.dart';
import 'package:client/features/tags/ui/widgets/tag_chip.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class CreateTaskTagsSelector extends StatelessWidget {
  const CreateTaskTagsSelector({
    super.key,
    required this.projectId,
    required this.selectedTags,
    required this.onTagAdded,
    required this.onTagRemoved,
  });

  final int projectId;
  final List<TagDto> selectedTags;
  final ValueChanged<TagDto> onTagAdded;
  final ValueChanged<TagDto> onTagRemoved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...selectedTags.map(
          (t) => TagChip(tag: t, onDeleted: () => onTagRemoved(t)),
        ),
        if (selectedTags.length < 5)
          InkWell(
            borderRadius: AppRadius.r6,
            onTap: () {
              AttachTagModal.show(
                context,
                projectId: projectId,
                currentTags: selectedTags,
                onTagSelected: onTagAdded,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                borderRadius: AppRadius.r6,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    size: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  AppSpacing.gapWXs,
                  Text(
                    l10n.tagLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
