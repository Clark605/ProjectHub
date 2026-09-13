import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/ambient_glow_state.dart';
import 'package:client/core/widgets/ambient_glow_painter.dart';

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

    if (!widget.showGlow) {
      return ColoredBox(
        color: theme.scaffoldBackgroundColor,
        child: widget.child,
      );
    }

    final effectivePrimary = widget.primaryGlowColor != AppColors.electricViolet
        ? widget.primaryGlowColor
        : theme.colorScheme.primary;
    final effectiveSecondary =
        widget.secondaryGlowColor != AppColors.electricVioletContainer
        ? widget.secondaryGlowColor
        : theme.colorScheme.secondary;
    final effectiveOpacity = isDark
        ? widget.glowOpacity
        : widget.glowOpacity * 2;

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
                Container(color: theme.scaffoldBackgroundColor),
                RepaintBoundary(
                  child: AnimatedBuilder(
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
                        painter: AmbientGlowPainter(
                          orbitVector: Offset(orbitX, orbitY),
                          pointerOffset: _state.smoothedPointerOffset,
                          primaryColor: effectivePrimary,
                          secondaryColor: effectiveSecondary,
                          opacity: effectiveOpacity,
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),
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
