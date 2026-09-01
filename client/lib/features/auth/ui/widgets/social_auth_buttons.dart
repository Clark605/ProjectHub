import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class SocialAuthSection extends StatelessWidget {
  const SocialAuthSection({
    super.key,
    this.onGooglePressed,
    this.onGithubPressed,
  });

  final VoidCallback? onGooglePressed;
  final VoidCallback? onGithubPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : AppColors.lightBorder;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: borderColor, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.orContinueWith,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ),
            Expanded(child: Divider(color: borderColor, thickness: 1)),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                iconWidget: const CustomPaint(
                  painter: _GoogleLogoPainter(),
                  size: Size(20, 20),
                ),
                label: 'Google',
                onPressed: onGooglePressed ?? () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SocialButton(
                iconWidget: CustomPaint(
                  painter: _GithubLogoPainter(
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  size: const Size(20, 20),
                ),
                label: 'GitHub',
                onPressed: onGithubPressed ?? () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.iconWidget,
    required this.label,
    required this.onPressed,
  });

  final Widget iconWidget;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.lightBorder;
    final textColor = isDark
        ? AppColors.textPrimary
        : AppColors.lightTextPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(width: 10),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

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

class _GithubLogoPainter extends CustomPainter {
  const _GithubLogoPainter({required this.color});
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
  bool shouldRepaint(covariant _GithubLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}
