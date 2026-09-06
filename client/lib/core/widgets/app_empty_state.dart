import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.inbox_outlined,
    this.ctaText,
    this.onCtaPressed,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? ctaText;
  final VoidCallback? onCtaPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (ctaText != null && onCtaPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onCtaPressed,
                child: Text(ctaText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
