import 'dart:math' as math;

import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_durations.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/theme/app_typography.dart';
import 'package:client/features/onboarding/ui/widgets/visuals/visual_canvas_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CollaborationVisual extends StatefulWidget {
  const CollaborationVisual({super.key});

  @override
  State<CollaborationVisual> createState() => _CollaborationVisualState();
}

class _CollaborationVisualState extends State<CollaborationVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motionController;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark
        ? AppColors.surfaceContainerHigh.withValues(alpha: 0.9)
        : AppColors.pureWhite;
    final cardBorder = context.appColors.subtleBorder;

    return VisualCanvasCard(
      primaryGlow: AppColors.electricViolet,
      secondaryGlow: AppColors.skyBlue,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Background Animated Sync Waves & Connection Lines ──
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _motionController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ConnectionWavePainter(
                    progress: _motionController.value,
                    isDark: isDark,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),

          // ── Top Presence Bar ──
          Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceContainerLow.withValues(alpha: 0.85)
                        : AppColors.lightSurfaceContainer,
                    borderRadius: AppRadius.lg,
                    border: Border.all(color: cardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                            width: 8,
                            height: 8,
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
                            begin: const Offset(0.7, 0.7),
                            end: const Offset(1.3, 1.3),
                            duration: 700.ms,
                          ),
                      AppSpacing.gapWSm,
                      Text(
                        '5 Team Members Online',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      AppSpacing.gapWSm,
                      _buildMiniAvatar('AK', AppColors.electricViolet),
                      AppSpacing.gapWXs,
                      _buildMiniAvatar('SR', AppColors.skyBlue),
                      AppSpacing.gapWXs,
                      _buildMiniAvatar('DM', AppColors.priorityHigh),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),

          // ── Central Collaborative Action Card ──
          Center(
                child: Container(
                  margin: const EdgeInsets.only(top: AppSpacing.xxl),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: AppRadius.lg,
                    border: Border.all(
                      color: isDark
                          ? AppColors.skyBlue.withValues(alpha: 0.25)
                          : AppColors.skyBlue.withValues(alpha: 0.3),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.skyBlue.withValues(
                          alpha: isDark ? 0.12 : 0.06,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: AppSpacing.edgeInsetsAllXs,
                            decoration: BoxDecoration(
                              color: AppColors.skyBlue.withValues(alpha: 0.15),
                              borderRadius: AppRadius.sm,
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: AppIconSize.sm,
                              color: AppColors.skyBlue,
                            ),
                          ),
                          AppSpacing.gapWSm,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Task Planning Thread',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Active discussion · 8 comments',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.gapHSm,
                      Container(
                        padding: AppSpacing.edgeInsetsAllSm,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceContainer
                              : AppColors.lightSurfaceContainer,
                          borderRadius: AppRadius.md,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: AppIconSize.xs,
                              color: AppColors.electricViolet,
                            ),
                            AppSpacing.gapWSm,
                            Expanded(
                              child: Text(
                                '"PR #104 merged! All tests passed 🚀"',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 500.ms, delay: 150.ms)
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                duration: 500.ms,
                curve: Curves.easeOutCubic,
              ),

          // ── Floating Dynamic User Cursor 1 (Alex - Violet) ──
          AnimatedBuilder(
            animation: _motionController,
            builder: (context, _) {
              final t = _motionController.value * 2 * math.pi;
              final dx = 30 + math.sin(t) * 22;
              final dy = 115 + math.cos(t) * 14;

              return Positioned(
                left: dx,
                top: dy,
                child: RepaintBoundary(
                  child: _buildLiveCursor(
                    name: 'Alex · Lead',
                    color: AppColors.electricViolet,
                    isTyping: false,
                  ),
                ),
              );
            },
          ),

          // ── Floating Dynamic User Cursor 2 (Sarah - Sky Blue with typing pill) ──
          AnimatedBuilder(
            animation: _motionController,
            builder: (context, _) {
              final t = (_motionController.value + 0.5) * 2 * math.pi;
              final dx = 180 + math.cos(t) * 20;
              final dy = 165 + math.sin(t) * 12;

              return Positioned(
                left: dx,
                top: dy,
                child: RepaintBoundary(
                  child: _buildLiveCursor(
                    name: 'Sarah · Dev',
                    color: AppColors.skyBlue,
                    isTyping: true,
                  ),
                ),
              );
            },
          ),

          // ── Bottom Real-Time Sync Indicator Toast ──
          Positioned(
                bottom: 4,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceContainerLow.withValues(alpha: 0.9)
                        : AppColors.pureWhite,
                    borderRadius: AppRadius.md,
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                            end: const Offset(1.4, 1.4),
                            duration: 600.ms,
                          ),
                      AppSpacing.gapWSm,
                      Text(
                        'Instant WebSocket Sync · 0ms Latency',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 350.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  Widget _buildMiniAvatar(String initials, Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: AppColors.pureWhite, width: 1),
      ),
      child: Center(
        child: Text(
          initials,
          style: Theme.of(context).textTheme.micro.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.pureWhite,
          ),
        ),
      ),
    );
  }

  Widget _buildLiveCursor({
    required String name,
    required Color color,
    required bool isTyping,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vector mouse cursor arrow
            CustomPaint(
              painter: _CursorPointerPainter(color: color),
              size: const Size(14, 14),
            ),
            AppSpacing.gapWXxs,
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: AppRadius.sm,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                name,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onElectricVioletContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        if (isTyping)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              top: AppSpacing.xxs,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.pureWhite.withValues(alpha: 0.9),
                borderRadius: AppRadius.sm,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pureBlack.withValues(alpha: 0.12),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTypingDot(0),
                  AppSpacing.gapWXxs,
                  _buildTypingDot(150),
                  AppSpacing.gapWXxs,
                  _buildTypingDot(300),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTypingDot(int delayMs) {
    return Container(
          width: 3.5,
          height: 3.5,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.skyBlueContainer,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.2, 1.2),
          delay: AppDurations.ms(delayMs),
          duration: 400.ms,
        );
  }
}

class _CursorPointerPainter extends CustomPainter {
  const _CursorPointerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.9)
      ..lineTo(size.width * 0.35, size.height * 0.65)
      ..lineTo(size.width * 0.8, size.height * 0.85)
      ..lineTo(size.width * 0.95, size.height * 0.7)
      ..lineTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width * 0.9, size.height * 0.4)
      ..close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.pureWhite
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CursorPointerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ConnectionWavePainter extends CustomPainter {
  const _ConnectionWavePainter({required this.progress, required this.isDark});

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = AppColors.electricViolet.withValues(
        alpha: (1.0 - progress) * (isDark ? 0.25 : 0.15),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final maxRadius = math.min(size.width, size.height) * 0.45;
    final currentRadius = maxRadius * progress;

    canvas.drawCircle(center, currentRadius, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _ConnectionWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
