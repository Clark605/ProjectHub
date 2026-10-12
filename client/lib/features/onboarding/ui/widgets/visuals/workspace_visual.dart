import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/onboarding/ui/widgets/visuals/visual_canvas_card.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class WorkspaceVisual extends StatelessWidget {
  const WorkspaceVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark
        ? AppColors.surfaceContainerHigh.withValues(alpha: 0.9)
        : AppColors.pureWhite;
    final cardBorder = AppColors.subtleBorder(isDark);

    return VisualCanvasCard(
      primaryGlow: AppColors.electricViolet,
      secondaryGlow: AppColors.skyBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Top Workspace Switcher Bar ──
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceContainerLow.withValues(alpha: 0.8)
                      : AppColors.lightSurfaceContainer,
                  borderRadius: AppRadius.lg,
                  border: Border.all(color: cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.electricViolet.withValues(alpha: 0.2),
                        borderRadius: AppRadius.md,
                      ),
                      child: const Icon(
                        Icons.dashboard_customize_rounded,
                        size: AppIconSize.md,
                        color: AppColors.electricViolet,
                      ),
                    ),
                    AppSpacing.gapWSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantum Mobile App',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '12 Active Projects · 8 Members',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: AppRadius.sm,
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.success,
                                ),
                              )
                              .animate(
                                onPlay: (controller) =>
                                    controller.repeat(reverse: true),
                              )
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1.3, 1.3),
                                duration: 800.ms,
                              ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'LIVE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),

          AppSpacing.gapHMd,

          // ── Main Floating Project Card ──
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                    padding: AppSpacing.edgeInsetsAllMd,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: AppRadius.lg,
                      border: Border.all(
                        color: isDark
                            ? AppColors.electricViolet.withValues(alpha: 0.25)
                            : AppColors.electricViolet.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricViolet.withValues(
                            alpha: isDark ? 0.15 : 0.08,
                          ),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xxs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.electricViolet.withValues(
                                      alpha: 0.18,
                                    ),
                                    borderRadius: AppRadius.sm,
                                  ),
                                  child: Text(
                                    'PROJECT 04',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.electricViolet,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                AppSpacing.gapWSm,
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: AppSpacing.xxs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.priorityHigh.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: AppRadius.sm,
                                  ),
                                  child: Text(
                                    l10n.priorityHigh.toUpperCase(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.priorityHigh,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '78%',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.skyBlue,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.gapHSm,
                        Text(
                          'Design System & UI Components',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSpacing.gapHSm,

                        // Animated Progress Bar
                        ClipRRect(
                          borderRadius: AppRadius.sm,
                          child: Stack(
                            children: [
                              Container(
                                height: 6,
                                width: double.infinity,
                                color: isDark
                                    ? AppColors.pureWhite.withValues(
                                        alpha: 0.08,
                                      )
                                    : AppColors.lightBorder,
                              ),
                              FractionallySizedBox(
                                widthFactor: 0.78,
                                child: Container(
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.electricViolet,
                                        AppColors.skyBlue,
                                      ],
                                    ),
                                  ),
                                ),
                              ).animate().scaleX(
                                begin: 0,
                                end: 1,
                                alignment: Alignment.centerLeft,
                                duration: 800.ms,
                                delay: 300.ms,
                                curve: Curves.easeOutCubic,
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.gapHSm,

                        // Avatar stack + task count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 80,
                              child: Stack(
                                children: [
                                  _buildAvatar(
                                    0,
                                    'AK',
                                    AppColors.electricViolet,
                                    AppColors.pureWhite,
                                  ),
                                  _buildAvatar(
                                    16,
                                    'SL',
                                    AppColors.skyBlue,
                                    AppColors.lightTextPrimary,
                                  ),
                                  _buildAvatar(
                                    32,
                                    'MD',
                                    AppColors.priorityHigh,
                                    AppColors.pureWhite,
                                  ),
                                  Positioned(
                                    left: 48,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDark
                                            ? AppColors.surfaceContainerHighest
                                            : AppColors.lightSurfaceContainer,
                                        border: Border.all(
                                          color: cardBg,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '+4',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: AppIconSize.xs,
                                  color: isDark
                                      ? AppColors.textSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                                AppSpacing.gapWXs,
                                Text(
                                  '18 / 24 Done',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondary
                                        : AppColors.lightTextSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 150.ms)
                  .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),

              // Floating Velocity Badge (top-right floating chip)
              Positioned(
                top: -12,
                right: 8,
                child: RepaintBoundary(
                  child:
                      Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.electricVioletContainer,
                                  AppColors.skyBlueContainer,
                                ],
                              ),
                              borderRadius: AppRadius.xl,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.electricViolet.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.bolt_rounded,
                                  size: AppIconSize.xs,
                                  color: AppColors.pureWhite,
                                ),
                                AppSpacing.gapWXs,
                                Text(
                                  '+42% Velocity',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.pureWhite,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true),
                          )
                          .moveY(
                            begin: 0,
                            end: -4,
                            duration: 1500.ms,
                            curve: Curves.easeInOut,
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 400.ms)
                          .scale(
                            duration: 400.ms,
                            delay: 400.ms,
                            curve: Curves.easeOutBack,
                          ),
                ),
              ),
            ],
          ),

          AppSpacing.gapHSm,

          // ── Bottom Secondary Task Pill ──
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: cardBg.withValues(alpha: 0.7),
                  borderRadius: AppRadius.md,
                  border: Border.all(color: cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.dns_rounded,
                      size: AppIconSize.sm,
                      color: AppColors.skyBlue,
                    ),
                    AppSpacing.gapWSm,
                    Expanded(
                      child: Text(
                        'API Core Engine v2',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      'GraphQL / REST',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.electricViolet,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  Widget _buildAvatar(double left, String initials, Color bg, Color textColor) {
    return Positioned(
      left: left,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
          border: Border.all(
            color: AppColors.pureWhite.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(fontWeight: FontWeight.w800, color: textColor),
          ),
        ),
      ),
    );
  }
}
