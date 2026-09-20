import 'package:flutter/material.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tags/ui/widgets/tag_chip.dart';

class AttachTagResults extends StatelessWidget {
  const AttachTagResults({
    super.key,
    required this.isLoading,
    required this.canCreate,
    required this.query,
    required this.filteredTags,
    required this.onCreateTag,
    required this.onSelectTag,
  });

  final bool isLoading;
  final bool canCreate;
  final String query;
  final List<TagDto> filteredTags;
  final ValueChanged<String> onCreateTag;
  final ValueChanged<TagDto> onSelectTag;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (canCreate)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.add_circle_outline,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              'Create "$query"',
              style: TextStyle(color: theme.colorScheme.primary, fontSize: 13),
            ),
            onTap: () => onCreateTag(query),
          ),
        if (filteredTags.isEmpty && !canCreate)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'No tags available',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filteredTags
                .map((tag) => TagChip(tag: tag, onTap: () => onSelectTag(tag)))
                .toList(),
          ),
      ],
    );
  }
}
