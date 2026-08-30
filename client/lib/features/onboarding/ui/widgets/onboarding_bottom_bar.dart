import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class OnboardingBottomBar extends StatelessWidget {
  const OnboardingBottomBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onGetStarted,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLastPage = currentPage == totalPages - 1;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(
              totalPages,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                height: 8,
                width: currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: currentPage == index
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          if (isLastPage)
            ElevatedButton(
              onPressed: onGetStarted,
              style: ElevatedButton.styleFrom(minimumSize: const Size(120, 52)),
              child: Text(l10n.getStarted),
            ).animate().fadeIn().scale()
          else
            TextButton(
              onPressed: onNext,
              style: TextButton.styleFrom(minimumSize: const Size(80, 52)),
              child: Text(l10n.next),
            ),
        ],
      ),
    );
  }
}
