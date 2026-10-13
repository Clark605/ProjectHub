import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/theme/workspace_accent.dart';
import 'package:client/features/shell/models/shell_tab.dart';
import 'package:flutter/material.dart';

class MobileBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final String? activeWorkspaceAccent;

  const MobileBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.activeWorkspaceAccent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final activeAccent =
        activeWorkspaceAccent != null &&
            activeWorkspaceAccent!.trim().isNotEmpty
        ? WorkspaceAccent.fromId(
            activeWorkspaceAccent,
          ).resolvedColor(theme.brightness)
        : theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ShellTab.values
                .map(
                  (tab) => Expanded(
                    child: _BottomNavItem(
                      icon: tab.selectedIcon,
                      label: tab.localizedName(l10n),
                      isSelected: selectedIndex == tab.index,
                      activeColor: activeAccent,
                      onTap: () => onItemSelected(tab.index),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inactiveColor = theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.md,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppIconSize.xl,
              color: isSelected ? activeColor : inactiveColor,
            ),
            AppSpacing.gapHXs,
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
