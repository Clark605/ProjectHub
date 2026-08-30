import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';

/// Global controller to persist ambient glow position & pointer state across routes
class AmbientGlowState {
  AmbientGlowState._();
  static final AmbientGlowState instance = AmbientGlowState._();

  final int _startEpoch = DateTime.now().millisecondsSinceEpoch;
  Offset pointerOffset = Offset.zero;
  Offset smoothedPointerOffset = Offset.zero;

  double getCycleProgress(int durationMs) {
    final elapsed = DateTime.now().millisecondsSinceEpoch - _startEpoch;
    return (elapsed % durationMs) / durationMs;
  }
}

class AmbientGlowBackground extends StatefulWidget {
  const AmbientGlowBackground({
    super.key,
    required this.child,
    this.showGlow = true,
    this.primaryGlowColor = AppColors.electricViolet,
    this.secondaryGlowColor = AppColors.electricVioletContainer,
    this.glowOpacity = 0.45,
    this.cycleDuration = const Duration(seconds: 14),
  });

  final Widget child;
  final bool showGlow;
  final Color primaryGlowColor;
  final Color secondaryGlowColor;
  final double glowOpacity;
  final Duration cycleDuration;

  @override
  State<AmbientGlowBackground> createState() => _AmbientGlowBackgroundState();
}

class _AmbientGlowBackgroundState extends State<AmbientGlowBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final _state = AmbientGlowState.instance;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onPointerMove(Offset localPosition, Size size) {
    if (size.width > 0 && size.height > 0) {
      _state.pointerOffset = Offset(
        (localPosition.dx / size.width - 0.5) * 2.0,
        (localPosition.dy / size.height - 0.5) * 2.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!widget.showGlow || !isDark) {
      return widget.child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return MouseRegion(
          onHover: (event) => _onPointerMove(event.localPosition, size),
          child: Listener(
            onPointerMove: (event) => _onPointerMove(event.localPosition, size),
            behavior: HitTestBehavior.translucent,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: AppColors.background),
                AnimatedBuilder(
                  animation: _ticker,
                  builder: (context, _) {
                    final progress = _state.getCycleProgress(
                      widget.cycleDuration.inMilliseconds,
                    );
                    final t = progress * 2 * math.pi;

                    _state.smoothedPointerOffset = Offset(
                      _state.smoothedPointerOffset.dx +
                          (_state.pointerOffset.dx -
                                  _state.smoothedPointerOffset.dx) *
                              0.08,
                      _state.smoothedPointerOffset.dy +
                          (_state.pointerOffset.dy -
                                  _state.smoothedPointerOffset.dy) *
                              0.08,
                    );

                    // Clockwise orbital trajectory (Top -> Right -> Bottom -> Left)
                    final orbitX = math.sin(t);
                    final orbitY = -math.cos(t);

                    return CustomPaint(
                      painter: _AmbientGlowPainter(
                        orbitVector: Offset(orbitX, orbitY),
                        pointerOffset: _state.smoothedPointerOffset,
                        primaryColor: widget.primaryGlowColor,
                        secondaryColor: widget.secondaryGlowColor,
                        opacity: widget.glowOpacity,
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                  child: const SizedBox.expand(),
                ),
                widget.child,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AmbientGlowPainter extends CustomPainter {
  _AmbientGlowPainter({
    required this.orbitVector,
    required this.pointerOffset,
    required this.primaryColor,
    required this.secondaryColor,
    required this.opacity,
  });

  final Offset orbitVector;
  final Offset pointerOffset;
  final Color primaryColor;
  final Color secondaryColor;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final interactiveX = pointerOffset.dx * width * 0.15;
    final interactiveY = pointerOffset.dy * height * 0.10;

    final orbitRadiusX = width * 0.28;
    final orbitRadiusY = height * 0.18;
    final baseCenter = Offset(width * 0.5, height * 0.22);

    final movingGlowCenter = Offset(
      baseCenter.dx + orbitVector.dx * orbitRadiusX + interactiveX,
      baseCenter.dy + orbitVector.dy * orbitRadiusY + interactiveY,
    );

    // Orb 1: Electric Violet (#c0c1ff)
    final violetCenter =
        movingGlowCenter + Offset(-width * 0.12, -height * 0.04);
    final violetRadius = math.max(width * 0.85, 340.0);
    final violetPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              primaryColor.withValues(alpha: opacity * 0.85),
              primaryColor.withValues(alpha: opacity * 0.4),
              primaryColor.withValues(alpha: opacity * 0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.35, 0.65, 1.0],
          ).createShader(
            Rect.fromCircle(center: violetCenter, radius: violetRadius),
          );

    canvas.drawCircle(violetCenter, violetRadius, violetPaint);

    // Orb 2: Sky Blue (#89ceff) trailing in the clockwise orbit
    final skyCenter = movingGlowCenter + Offset(width * 0.14, height * 0.04);
    final skyRadius = math.max(width * 0.8, 320.0);
    final skyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          secondaryColor.withValues(alpha: opacity * 0.75),
          secondaryColor.withValues(alpha: opacity * 0.35),
          secondaryColor.withValues(alpha: opacity * 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: skyCenter, radius: skyRadius));

    canvas.drawCircle(skyCenter, skyRadius, skyPaint);

    // Orb 3: Interactive Follower Light
    if (pointerOffset != Offset.zero) {
      final followCenter = Offset(
        width * 0.5 + pointerOffset.dx * (width * 0.38),
        height * 0.4 + pointerOffset.dy * (height * 0.28),
      );
      final followRadius = math.max(width * 0.45, 180.0);
      final followPaint = Paint()
        ..shader =
            RadialGradient(
              colors: [
                primaryColor.withValues(alpha: opacity * 0.25),
                secondaryColor.withValues(alpha: opacity * 0.1),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(
              Rect.fromCircle(center: followCenter, radius: followRadius),
            );

      canvas.drawCircle(followCenter, followRadius, followPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientGlowPainter oldDelegate) {
    return oldDelegate.orbitVector != orbitVector ||
        oldDelegate.pointerOffset != pointerOffset ||
        oldDelegate.opacity != opacity;
  }
}
