import 'package:flutter/material.dart';

import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tags/ui/widgets/attach_tag_modal.dart';
import 'package:client/features/tags/ui/widgets/tag_chip.dart';

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

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...selectedTags.map(
          (t) => TagChip(tag: t, onDeleted: () => onTagRemoved(t)),
        ),
        if (selectedTags.length < 5)
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () {
              AttachTagModal.show(
                context,
                projectId: projectId,
                currentTags: selectedTags,
                onTagSelected: onTagAdded,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
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
                  const SizedBox(width: 4),
                  Text(
                    'Tag',
                    style: TextStyle(
                      fontSize: 12,
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
