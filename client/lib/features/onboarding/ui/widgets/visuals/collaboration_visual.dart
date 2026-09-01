import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/onboarding/ui/widgets/visuals/visual_canvas_card.dart';

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
        : Colors.white;
    final cardBorder = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : AppColors.lightBorder;

    return VisualCanvasCard(
      primaryGlow: AppColors.electricViolet,
      secondaryGlow: AppColors.skyBlue,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Background Animated Sync Waves & Connection Lines ──
          AnimatedBuilder(
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

          // ── Top Presence Bar ──
          Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceContainerLow.withValues(alpha: 0.85)
                        : AppColors.lightSurfaceContainer,
                    borderRadius: BorderRadius.circular(16),
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
                      const SizedBox(width: 8),
                      Text(
                        '5 Team Members Online',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildMiniAvatar('AK', AppColors.electricViolet),
                      const SizedBox(width: 4),
                      _buildMiniAvatar('SR', AppColors.skyBlue),
                      const SizedBox(width: 4),
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
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
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
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.skyBlue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 16,
                              color: AppColors.skyBlue,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sprint Planning Thread',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Active discussion · 8 comments',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondary
                                        : AppColors.lightTextSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceContainer
                              : AppColors.lightSurfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 14,
                              color: AppColors.electricViolet,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '"PR #104 merged! All tests passed 🚀"',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
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
                child: _buildLiveCursor(
                  name: 'Alex · Lead',
                  color: AppColors.electricViolet,
                  isTyping: false,
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
                child: _buildLiveCursor(
                  name: 'Sarah · Dev',
                  color: AppColors.skyBlue,
                  isTyping: true,
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
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceContainerLow.withValues(alpha: 0.9)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
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
                      const SizedBox(width: 8),
                      Text(
                        'Instant WebSocket Sync · 0ms Latency',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.5,
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
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w800,
            color: Colors.white,
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
            const SizedBox(width: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
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
                style: const TextStyle(
                  color: Color(0xFF0D0096),
                  fontWeight: FontWeight.w800,
                  fontSize: 8.5,
                ),
              ),
            ),
          ],
        ),
        if (isTyping)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTypingDot(0),
                  const SizedBox(width: 2),
                  _buildTypingDot(150),
                  const SizedBox(width: 2),
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
          delay: Duration(milliseconds: delayMs),
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
      ..color = Colors.white
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
