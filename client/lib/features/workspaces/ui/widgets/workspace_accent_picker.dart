import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

import 'package:client/core/theme/workspace_accent.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class WorkspaceAccentPicker extends StatelessWidget {
  final String? activeAccentId;
  final ValueChanged<String> onAccentSelected;

  const WorkspaceAccentPicker({
    super.key,
    required this.activeAccentId,
    required this.onAccentSelected,
  });

  static const double _pickerHeight = 44.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.palette_outlined,
              size: AppIconSize.md,
              color: theme.colorScheme.primary,
            ),
            AppSpacing.gapWSm,
            Text(
              l10n.accentColor,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        AppSpacing.gapHXs,
        Text(
          l10n.accentColorSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.gapHMd,
        SizedBox(
          height: _pickerHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: WorkspaceAccent.values.length,
            separatorBuilder: (_, _) => AppSpacing.gapWSm,
            itemBuilder: (context, index) {
              final accent = WorkspaceAccent.values[index];
              final isSelected = activeAccentId == accent.id;
              final color = accent.resolvedColor(theme.brightness);
              return Tooltip(
                message: accent.name,
                child: InkWell(
                  onTap: () => onAccentSelected(accent.id),
                  borderRadius: AppRadius.xl,
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
                            size: AppIconSize.lg,
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
