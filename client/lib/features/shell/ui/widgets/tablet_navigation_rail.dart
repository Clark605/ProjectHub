import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/shell/models/shell_tab.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class TabletNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const TabletNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        border: BorderDirectional(
          end: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        children: [
          AppSpacing.gapHLg,
          // Logo Icon
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.electricViolet, AppColors.skyBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.md,
            ),
            child: const Center(
              child: Icon(
                Icons.hub_rounded,
                color: AppColors.onElectricViolet,
                size: AppIconSize.lg,
              ),
            ),
          ),
          AppSpacing.gapHXxl,
          Divider(color: theme.colorScheme.outlineVariant, height: 1),
          AppSpacing.gapHLg,

          // Rail Nav Items
          ...ShellTab.values.map(
            (tab) => Column(
              children: [
                _RailItem(
                  icon: tab.selectedIcon,
                  label: tab.localizedName(l10n),
                  isSelected: selectedIndex == tab.index,
                  onTap: () => onItemSelected(tab.index),
                ),
                if (tab != ShellTab.profile) AppSpacing.gapHMd,
              ],
            ),
          ),

          const Spacer(),
          AppSpacing.gapHLg,
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RailItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      preferBelow: false,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: AppRadius.md,
            border: isSelected
                ? Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  )
                : null,
          ),
          child: Icon(
            icon,
            size: AppIconSize.xl,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
