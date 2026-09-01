import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class OnboardingBottomBar extends StatelessWidget {
  const OnboardingBottomBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onGetStarted,
    this.onDotTap,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;
  final ValueChanged<int>? onDotTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLastPage = currentPage == totalPages - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Interactive Page Indicator Pills ──
          Row(
            children: List.generate(totalPages, (index) {
              final isActive = currentPage == index;
              return GestureDetector(
                onTap: () => onDotTap?.call(index),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 3,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    height: 8,
                    width: isActive ? 30 : 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: isActive
                          ? const LinearGradient(
                              colors: [
                                AppColors.electricViolet,
                                AppColors.skyBlue,
                              ],
                            )
                          : null,
                      color: isActive
                          ? null
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.18)
                                : AppColors.lightBorder),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.electricViolet.withValues(
                                  alpha: isDark ? 0.45 : 0.3,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              );
            }),
          ),

          // ── Action CTA Button ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: isLastPage
                ? Container(
                    key: const ValueKey('get_started_btn'),
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [AppColors.electricViolet, Color(0xFF9E77ED)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricViolet.withValues(
                            alpha: isDark ? 0.45 : 0.3,
                          ),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onGetStarted,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.getStarted,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                  color: AppColors.textOnPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: AppColors.textOnPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
                    key: const ValueKey('next_btn'),
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceContainerHigh
                          : AppColors.lightSurfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onNext,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.next,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5,
                                  color: isDark
                                      ? AppColors.textPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 17,
                                color: isDark
                                    ? AppColors.electricViolet
                                    : AppColors.lightTextPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
