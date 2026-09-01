import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:client/core/theme/app_colors.dart';

class OnboardingPageItem extends StatelessWidget {
  const OnboardingPageItem({
    super.key,
    required this.tag,
    required this.title,
    required this.description,
    required this.visual,
  });

  final String tag;
  final String title;
  final String description;
  final Widget visual;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Visual Canvas ──
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: visual
                    .animate()
                    .fadeIn(duration: 450.ms, curve: Curves.easeOutCubic)
                    .scale(
                      begin: const Offset(0.92, 0.92),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Category Tag Chip ──
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.electricViolet.withValues(alpha: 0.12)
                      : AppColors.electricViolet.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.electricViolet.withValues(
                      alpha: isDark ? 0.35 : 0.45,
                    ),
                    width: 1.1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.electricViolet,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tag,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppColors.electricViolet
                            : const Color(0xFF3730A3),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 350.ms, delay: 150.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

          const SizedBox(height: 12),

          // ── Headline Title ──
          Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.lightTextPrimary,
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 220.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

          const SizedBox(height: 10),

          // ── Subtitle Description ──
          ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                    height: 1.45,
                    fontSize: 14.5,
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
