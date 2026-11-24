import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// CustomPainter rendering a glowing, anti-aliased circular Pomodoro progress ring.
class CircularTimerPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final bool isBreak;
  final bool isDark;
  final Color? primaryColor;
  final Color? secondaryColor;

  const CircularTimerPainter({
    required this.progress,
    required this.isBreak,
    required this.isDark,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 14.0;
    const strokeWidth = 12.0;

    // 1. Background Track
    final trackPaint = Paint()
      ..color = isDark
          ? const Color(0xFF1E293B)
          : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0.0) return;

    // 2. Animated Progress Arc
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    const startAngle = -math.pi / 2; // Start at top 12 o'clock

    final pColor = primaryColor ?? AppColors.primary;
    final sColor = secondaryColor ?? AppColors.secondary;

    final gradientColors = isBreak
        ? [AppColors.accentEmerald, sColor]
        : [pColor, sColor];

    final arcPaint = Paint()
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: 0.0,
        endAngle: 2 * math.pi,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    // 3. Glowing leading handle indicator
    final handleAngle = startAngle + sweepAngle;
    final handleX = center.dx + radius * math.cos(handleAngle);
    final handleY = center.dy + radius * math.sin(handleAngle);

    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(handleX, handleY), strokeWidth / 2, handlePaint);
  }

  @override
  bool shouldRepaint(covariant CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isBreak != isBreak ||
        oldDelegate.isDark != isDark;
  }
}
