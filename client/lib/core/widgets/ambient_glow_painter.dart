import 'dart:math' as math;
import 'package:flutter/material.dart';

class AmbientGlowPainter extends CustomPainter {
  AmbientGlowPainter({
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

    // Orb 1: Electric Violet (#c0c1ff) with smooth diffuse multi-stop falloff
    final violetCenter =
        movingGlowCenter + Offset(-width * 0.12, -height * 0.04);
    final violetRadius = math.max(width * 0.95, 380.0);
    final violetPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              primaryColor.withValues(alpha: opacity * 0.50),
              primaryColor.withValues(alpha: opacity * 0.35),
              primaryColor.withValues(alpha: opacity * 0.18),
              primaryColor.withValues(alpha: opacity * 0.05),
              primaryColor.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.25, 0.55, 0.80, 1.0],
          ).createShader(
            Rect.fromCircle(center: violetCenter, radius: violetRadius),
          );

    canvas.drawCircle(violetCenter, violetRadius, violetPaint);

    // Orb 2: Sky Blue (#89ceff) trailing in the clockwise orbit
    final skyCenter = movingGlowCenter + Offset(width * 0.14, height * 0.04);
    final skyRadius = math.max(width * 0.90, 360.0);
    final skyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          secondaryColor.withValues(alpha: opacity * 0.45),
          secondaryColor.withValues(alpha: opacity * 0.30),
          secondaryColor.withValues(alpha: opacity * 0.14),
          secondaryColor.withValues(alpha: opacity * 0.04),
          secondaryColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.25, 0.55, 0.80, 1.0],
      ).createShader(Rect.fromCircle(center: skyCenter, radius: skyRadius));

    canvas.drawCircle(skyCenter, skyRadius, skyPaint);

    // Orb 3: Interactive Follower Light
    if (pointerOffset != Offset.zero) {
      final followCenter = Offset(
        width * 0.5 + pointerOffset.dx * (width * 0.38),
        height * 0.4 + pointerOffset.dy * (height * 0.28),
      );
      final followRadius = math.max(width * 0.55, 220.0);
      final followPaint = Paint()
        ..shader =
            RadialGradient(
              colors: [
                primaryColor.withValues(alpha: opacity * 0.25),
                secondaryColor.withValues(alpha: opacity * 0.12),
                secondaryColor.withValues(alpha: opacity * 0.03),
                secondaryColor.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.35, 0.70, 1.0],
            ).createShader(
              Rect.fromCircle(center: followCenter, radius: followRadius),
            );

      canvas.drawCircle(followCenter, followRadius, followPaint);
    }
  }

  @override
  bool shouldRepaint(covariant AmbientGlowPainter oldDelegate) {
    return oldDelegate.orbitVector != orbitVector ||
        oldDelegate.pointerOffset != pointerOffset ||
        oldDelegate.opacity != opacity;
  }
}
