import 'package:flutter/material.dart';

class GoogleLogoPainter extends CustomPainter {
  const GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // Red sector (top)
    final redPaint = Paint()..color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 * 0.75,
        3.14159 * 0.5,
        false,
      )
      ..close();
    canvas.drawPath(redPath, redPaint);

    // Yellow sector (left)
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 * 1.25,
        3.14159 * 0.5,
        false,
      )
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Green sector (bottom)
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        3.14159 * 0.25,
        3.14159 * 0.5,
        false,
      )
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Blue sector (right & crossbar)
    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 * 0.25,
        3.14159 * 0.5,
        false,
      )
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // Inner cutout circle
    final whiteCutoutPaint = Paint()..color = const Color(0xFF1F1F27);
    canvas.drawCircle(center, radius * 0.58, whiteCutoutPaint);

    // Right crossbar
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx, center.dy - radius * 0.22, radius, radius * 0.44),
      Radius.circular(radius * 0.1),
    );
    canvas.drawRRect(barRect, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
