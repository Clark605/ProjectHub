import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tags/ui/widgets/attach_tag_modal.dart';
import 'package:client/features/tags/ui/widgets/tag_chip.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

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
    final l10n = context.l10n;
    if (tags.isEmpty && !canEdit) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
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
            borderRadius: AppRadius.sm,
            onTap: () => AttachTagModal.show(
              context,
              projectId: projectId,
              currentTags: tags,
              onTagSelected: onTagAdded!,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                borderRadius: AppRadius.sm,
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
                    size: AppIconSize.xxs,
                    color: AppColors.textSecondary,
                  ),
                  AppSpacing.gapWXxs,
                  Text(
                    l10n.tagLabel,
                    style: const TextStyle(
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
