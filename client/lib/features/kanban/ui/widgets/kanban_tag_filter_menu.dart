import 'package:flutter/material.dart';

import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tags/ui/widgets/tag_chip.dart';

class KanbanTagFilterMenu extends StatelessWidget {
  final int? selectedTagId;
  final List<TagDto> availableTags;
  final ValueChanged<int?> onTagSelected;

  const KanbanTagFilterMenu({
    super.key,
    required this.selectedTagId,
    required this.availableTags,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (availableTags.isEmpty) return const SizedBox.shrink();

    final hasSelection = selectedTagId != null;
    final selectedTag =
        availableTags.where((t) => t.id == selectedTagId).firstOrNull;

    return PopupMenuButton<int?>(
      tooltip: 'Filter by tag',
      onSelected: onTagSelected,
      child: Chip(
        avatar: Icon(
          Icons.local_offer_outlined,
          size: 16,
          color: selectedTag != null
              ? TagChip.parseHexColor(selectedTag.color)
              : null,
        ),
        label: Text(
          selectedTag != null ? 'Tag: ${selectedTag.name}' : 'Tags',
          style: TextStyle(
            fontSize: 12,
            fontWeight: hasSelection ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        deleteIcon:
            hasSelection ? const Icon(Icons.close_rounded, size: 14) : null,
        onDeleted: hasSelection ? () => onTagSelected(null) : null,
      ),
      itemBuilder: (context) => [
        const PopupMenuItem<int?>(
          value: null,
          child: Text('All Tags'),
        ),
        ...availableTags.map(
          (t) => PopupMenuItem<int?>(
            value: t.id,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: TagChip.parseHexColor(t.color),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(t.name),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
