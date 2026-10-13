import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class ActivityQuickFilterBar extends StatelessWidget {
  final String currentCategory;
  final ValueChanged<String> onCategorySelected;

  const ActivityQuickFilterBar({
    super.key,
    required this.currentCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final categories = [
      {'key': 'All', 'label': l10n.allActivities},
      {'key': 'Tasks', 'label': l10n.taskActivities},
      {'key': 'Projects', 'label': l10n.projectActivities},
      {'key': 'Members', 'label': l10n.memberActivities},
    ];

    final isDark = theme.brightness == Brightness.dark;
    final selectedBgColor = isDark
        ? AppColors.primary.withValues(alpha: 0.22)
        : AppColors.primaryContainer.withValues(alpha: 0.18);
    final selectedTextColor = isDark
        ? AppColors.primary
        : AppColors.onElectricVioletContainer;
    final unselectedTextColor = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final selectedBorderColor = isDark
        ? AppColors.primary
        : AppColors.primaryContainer;
    final unselectedBorderColor = isDark
        ? AppColors.border
        : AppColors.lightBorder;

    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.edgeInsetsHLg,
        itemCount: categories.length,
        separatorBuilder: (_, _) => AppSpacing.gapWSm,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = currentCategory == cat['key'];
          return ChoiceChip(
            key: Key('activity_quick_filter_${cat['key']}'),
            label: Text(cat['label']!),
            selected: isSelected,
            selectedColor: selectedBgColor,
            checkmarkColor: selectedTextColor,
            side: BorderSide(
              color: isSelected ? selectedBorderColor : unselectedBorderColor,
              width: isSelected ? 1.5 : 1.0,
            ),
            labelStyle: theme.textTheme.labelMedium?.copyWith(
              color: isSelected ? selectedTextColor : unselectedTextColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            onSelected: (selected) {
              if (selected) {
                onCategorySelected(cat['key']!);
              }
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
          );
        },
      ),
    );
  }
}
