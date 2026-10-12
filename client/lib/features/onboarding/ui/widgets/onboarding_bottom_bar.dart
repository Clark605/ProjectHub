import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLastPage = currentPage == totalPages - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.md,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
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
                    vertical: AppSpacing.sm,
                    horizontal: AppSpacing.xxs,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    height: 8,
                    width: isActive ? 30 : 8,
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.r6,
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
                                ? AppColors.pureWhite.withValues(alpha: 0.18)
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
                      borderRadius: AppRadius.r16,
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.electricViolet,
                          AppColors.violetGradientEnd,
                        ],
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
                        borderRadius: AppRadius.r16,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.getStarted,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                  color: AppColors.textOnPrimary,
                                ),
                              ),
                              AppSpacing.gapWSm,
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
                      borderRadius: AppRadius.r16,
                      border: Border.all(
                        color: isDark
                            ? AppColors.pureWhite.withValues(alpha: 0.12)
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onNext,
                        borderRadius: AppRadius.r16,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.next,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.textPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              AppSpacing.gapWXs,
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
