import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/onboarding/ui/widgets/visuals/visual_canvas_card.dart';

class WorkspaceVisual extends StatelessWidget {
  const WorkspaceVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark
        ? AppColors.surfaceContainerHigh.withValues(alpha: 0.9)
        : Colors.white;
    final cardBorder = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : AppColors.lightBorder;

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
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceContainerLow.withValues(alpha: 0.8)
                      : AppColors.lightSurfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.electricViolet.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.dashboard_customize_rounded,
                        size: 18,
                        color: AppColors.electricViolet,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantum Mobile App',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
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
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
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
                          const SizedBox(width: 5),
                          Text(
                            'LIVE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
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

          const SizedBox(height: 12),

          // ── Main Floating Project Card ──
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
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
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.electricViolet.withValues(
                                      alpha: 0.18,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'SPRINT 04',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.electricViolet,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.priorityHigh.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'HIGH',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.priorityHigh,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 9,
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
                        const SizedBox(height: 8),
                        Text(
                          'Design System & UI Components',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Animated Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Stack(
                            children: [
                              Container(
                                height: 6,
                                width: double.infinity,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
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
                        const SizedBox(height: 10),

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
                                    Colors.white,
                                  ),
                                  _buildAvatar(
                                    16,
                                    'SL',
                                    AppColors.skyBlue,
                                    const Color(0xFF0F172A),
                                  ),
                                  _buildAvatar(
                                    32,
                                    'MD',
                                    const Color(0xFFF43F5E),
                                    Colors.white,
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
                                                fontSize: 9,
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
                                  size: 14,
                                  color: isDark
                                      ? AppColors.textSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '18 / 24 Done',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondary
                                        : AppColors.lightTextSecondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
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
                child:
                    Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.electricVioletContainer,
                                AppColors.skyBlueContainer,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
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
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+42% Velocity',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
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
            ],
          ),

          const SizedBox(height: 10),

          // ── Bottom Secondary Task Pill ──
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: cardBg.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.dns_rounded,
                      size: 16,
                      color: AppColors.skyBlue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'API Core Engine v2',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      'GraphQL / REST',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.electricViolet,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
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
            color: Colors.white.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
