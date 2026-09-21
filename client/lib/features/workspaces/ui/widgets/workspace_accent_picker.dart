import 'package:flutter/material.dart';

import 'package:client/core/theme/workspace_accent.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class WorkspaceAccentPicker extends StatelessWidget {
  final String? activeAccentId;
  final ValueChanged<String> onAccentSelected;

  const WorkspaceAccentPicker({
    super.key,
    required this.activeAccentId,
    required this.onAccentSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.palette_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              l10n?.accentColor ?? 'Accent Color',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n?.accentColorSubtitle ??
              'Subtle wayfinding color for workspace indicators and tabs.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: WorkspaceAccent.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final accent = WorkspaceAccent.values[index];
              final isSelected = activeAccentId == accent.id;
              final color = accent.resolvedColor(theme.brightness);
              return Tooltip(
                message: accent.name,
                child: InkWell(
                  onTap: () => onAccentSelected(accent.id),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.onSurface
                            : Colors.transparent,
                        width: isSelected ? 2.5 : 0,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: accent.resolvedOnAccent(theme.brightness),
                            size: 20,
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
