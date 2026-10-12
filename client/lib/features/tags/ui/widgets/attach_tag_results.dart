import 'package:flutter/material.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tags/ui/widgets/tag_chip.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

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
          padding: EdgeInsets.all(AppSpacing.lg),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final theme = Theme.of(context);
    final l10n = context.l10n;
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
              l10n.createTagQuery(query),
              style: TextStyle(color: theme.colorScheme.primary),
            ),
            onTap: () => onCreateTag(query),
          ),
        if (filteredTags.isEmpty && !canCreate)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(
              child: Text(
                l10n.noTagsAvailable,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          )
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: filteredTags
                .map((tag) => TagChip(tag: tag, onTap: () => onSelectTag(tag)))
                .toList(),
          ),
      ],
    );
  }
}
