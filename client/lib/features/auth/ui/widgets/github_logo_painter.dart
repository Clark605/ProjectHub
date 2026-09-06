import 'package:flutter/material.dart';

class GithubLogoPainter extends CustomPainter {
  const GithubLogoPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path = Path();
    // Simplified elegant GitHub Octocat mark
    path.addOval(Rect.fromLTWH(0, 0, w, h));

    // Ear notches / face cutout
    final cutout = Path()
      ..moveTo(w * 0.25, h * 0.6)
      ..quadraticBezierTo(w * 0.2, h * 0.85, w * 0.35, h * 0.9)
      ..quadraticBezierTo(w * 0.5, h * 0.75, w * 0.65, h * 0.9)
      ..quadraticBezierTo(w * 0.8, h * 0.85, w * 0.75, h * 0.6)
      ..quadraticBezierTo(w * 0.5, h * 0.45, w * 0.25, h * 0.6)
      ..close();

    final result = Path.combine(PathOperation.difference, path, cutout);
    canvas.drawPath(result, paint);
  }

  @override
  bool shouldRepaint(covariant GithubLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}
