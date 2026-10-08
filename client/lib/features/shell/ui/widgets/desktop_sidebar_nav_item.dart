import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

class DesktopSidebarNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final String? badge;
  final Color? badgeColor;
  final Color? selectedAccentColor;
  final VoidCallback onTap;

  const DesktopSidebarNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    this.badge,
    this.badgeColor,
    this.selectedAccentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = selectedAccentColor ?? theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.r10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: AppRadius.r10,
          border: isSelected
              ? Border.all(color: activeColor.withValues(alpha: 0.4), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? activeColor
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? activeColor : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (badgeColor ?? activeColor).withValues(alpha: 0.15),
                  borderRadius: AppRadius.r10,
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: badgeColor ?? activeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
