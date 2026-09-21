import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tags/ui/widgets/attach_tag_modal.dart';
import 'package:client/features/tags/ui/widgets/tag_chip.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class TaskTagsRow extends StatelessWidget {
  const TaskTagsRow({
    super.key,
    required this.projectId,
    required this.tags,
    this.canEdit = false,
    this.onTagAdded,
    this.onTagRemoved,
  });

  final int projectId;
  final List<TagDto> tags;
  final bool canEdit;
  final ValueChanged<TagDto>? onTagAdded;
  final ValueChanged<TagDto>? onTagRemoved;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (tags.isEmpty && !canEdit) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...tags.map(
          (tag) => TagChip(
            tag: tag,
            onDeleted: canEdit && onTagRemoved != null
                ? () => onTagRemoved!(tag)
                : null,
          ),
        ),
        if (canEdit && tags.length < 5 && onTagAdded != null)
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => AttachTagModal.show(
              context,
              projectId: projectId,
              currentTags: tags,
              onTagSelected: onTagAdded!,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    l10n?.tagLabel ?? 'Tag',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
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
