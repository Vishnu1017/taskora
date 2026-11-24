import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/theme_provider.dart';

/// Modern Signature Taskora Emblem.
/// Features:
/// 1. Precision Multi-Ring Gyroscope (Outer Compass + Counter-rotating Dashed Track).
/// 2. 3D Floating Zero-G Perspective Tilt with interactive touch reaction.
/// 3. Glass Specular Sheen (Shimmer light-sweep across the prism face).
/// 4. Laser Checkmark with trailing kinetic sparks.
/// 5. Dual Concentric Resonance Shockwaves expanding on checkmark completion.
/// 6. Fully synchronized to the active [AppThemePalette].
class AnimatedTaskoraEmblem extends StatelessWidget {
  final double scale;
  final double checkmarkProgress;
  final double ringProgress;
  final double rippleProgress;
  final double glowOpacity;
  final double shimmerProgress;
  final double floatAngle;
  final Offset touchOffset;
  final double size;
  final AppThemePalette palette;

  const AnimatedTaskoraEmblem({
    super.key,
    required this.scale,
    required this.checkmarkProgress,
    required this.palette,
    this.ringProgress = 1.0,
    this.rippleProgress = 0.0,
    this.glowOpacity = 1.0,
    this.shimmerProgress = 0.0,
    this.floatAngle = 0.0,
    this.touchOffset = Offset.zero,
    this.size = 130.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = palette.primaryColor;
    final secondary = palette.secondaryColor;
    final sparkColor = palette.secondaryLightColor;

    // Floating zero-gravity tilt combined with interactive touch parallax
    final naturalTiltX = math.sin(floatAngle) * 0.06;
    final naturalTiltY = math.cos(floatAngle * 0.8) * 0.06;
    final targetTiltX = (naturalTiltX - (touchOffset.dy * 0.18)).clamp(-0.25, 0.25);
    final targetTiltY = (naturalTiltY + (touchOffset.dx * 0.18)).clamp(-0.25, 0.25);

    return Transform.scale(
      scale: scale,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0012) // 3D Perspective field of view
          ..rotateX(targetTiltX)
          ..rotateY(targetTiltY),
        alignment: Alignment.center,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Primary & Secondary Resonance Shockwaves expanding upon checkmark lock
              if (rippleProgress > 0.0) ...[
                // Outer Shockwave Wave 1
                Transform.scale(
                  scale: 1.0 + (rippleProgress * 0.55),
                  child: Container(
                    width: size * 0.92,
                    height: size * 0.92,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size * 0.32),
                      border: Border.all(
                        color: primary.withValues(
                          alpha: (1.0 - rippleProgress).clamp(0.0, 0.70),
                        ),
                        width: 2.4 * (1.0 - rippleProgress * 0.75),
                      ),
                    ),
                  ),
                ),
                // Inner Shockwave Wave 2 (delayed stagger)
                if (rippleProgress > 0.12)
                  Transform.scale(
                    scale: 1.0 + ((rippleProgress - 0.12) / 0.88 * 0.40),
                    child: Container(
                      width: size * 0.84,
                      height: size * 0.84,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size * 0.28),
                        border: Border.all(
                          color: secondary.withValues(
                            alpha: (1.0 - (rippleProgress - 0.12) / 0.88).clamp(0.0, 0.50),
                          ),
                          width: 1.6 * (1.0 - rippleProgress),
                        ),
                      ),
                    ),
                  ),
              ],

              // 2. Ambient Neon Backglow Halo (Impeller-safe direct alpha modulation)
              Container(
                width: size * 0.88,
                height: size * 0.88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size * 0.32),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(
                        alpha: (isDark ? 0.50 : 0.32) * glowOpacity.clamp(0.0, 1.0),
                      ),
                      blurRadius: 42,
                      spreadRadius: 8,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: secondary.withValues(
                        alpha: (isDark ? 0.30 : 0.18) * glowOpacity.clamp(0.0, 1.0),
                      ),
                      blurRadius: 28,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
              ),

              // 3. Precision Dual-Ring Gyroscope System (CustomPainter)
              CustomPaint(
                size: Size(size, size),
                painter: _TaskoraGyroscopeRingsPainter(
                  progress: ringProgress,
                  floatAngle: floatAngle,
                  color1: primary,
                  color2: secondary,
                  sparkColor: sparkColor,
                  isDark: isDark,
                ),
              ),

              // 4. Prism Squircle Core Outer Shell
              Container(
                width: size * 0.76,
                height: size * 0.76,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size * 0.26),
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [
                            Color(0xFF2C3258),
                            Color(0xFF101322),
                          ]
                        : const [
                            Colors.white,
                            Color(0xFFF1F5F9),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF475569).withValues(alpha: 0.75)
                        : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  // Inner Vibrant Radiant Shield with Palette Gradient
                  child: Container(
                    width: size * 0.60,
                    height: size * 0.60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size * 0.20),
                      gradient: palette.gradient,
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.55),
                          blurRadius: 18,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(size * 0.20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Specular glass highlight at top-left
                          Positioned(
                            top: -size * 0.1,
                            left: -size * 0.1,
                            child: Container(
                              width: size * 0.42,
                              height: size * 0.42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.42),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Dynamic Crystalline Specular Light Sheen Sweep
                          if (shimmerProgress > 0.0 && shimmerProgress < 1.0)
                            Positioned.fill(
                              child: Transform.rotate(
                                angle: -math.pi / 4,
                                child: FractionalTranslation(
                                  translation: Offset(
                                    (shimmerProgress * 2.6) - 1.3,
                                    0.0,
                                  ),
                                  child: Container(
                                    width: size * 0.25,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withValues(alpha: 0.0),
                                          Colors.white.withValues(alpha: 0.45),
                                          Colors.white.withValues(alpha: 0.0),
                                        ],
                                        stops: const [0.0, 0.5, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Animated Laser Checkmark with Kinetic Leading & Trailing Sparks
                          CustomPaint(
                            size: Size(size * 0.38, size * 0.38),
                            painter: _TaskoraModernCheckmarkPainter(
                              progress: checkmarkProgress,
                              color: Colors.white,
                              sparkColor: sparkColor,
                              strokeWidth: 4.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws a dual-ring quantum gyroscope system:
/// 1. Outer Compass Ring with tick marks, sweep progress, and leading orb spark.
/// 2. Inner Counter-rotating Dashed Gyro Track.
class _TaskoraGyroscopeRingsPainter extends CustomPainter {
  final double progress;
  final double floatAngle;
  final Color color1;
  final Color color2;
  final Color sparkColor;
  final bool isDark;

  _TaskoraGyroscopeRingsPainter({
    required this.progress,
    required this.floatAngle,
    required this.color1,
    required this.color2,
    required this.sparkColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 2.5;
    final innerRadius = size.width * 0.43;

    // --- 1. Inner Counter-Rotating Dashed Orbit Track ---
    final innerTrackPaint = Paint()
      ..color = (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))
          .withValues(alpha: 0.35 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const int dashSegments = 16;
    final dashSweep = (2 * math.pi) / dashSegments;
    final innerAngleOffset = -floatAngle * 0.7;

    for (int i = 0; i < dashSegments; i++) {
      if (i % 2 == 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: innerRadius),
          innerAngleOffset + (i * dashSweep),
          dashSweep * 0.6,
          false,
          innerTrackPaint,
        );
      }
    }

    // --- 2. Outer Track Ring Base ---
    final outerTrackPaint = Paint()
      ..color = (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
          .withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.drawCircle(center, outerRadius, outerTrackPaint);

    // --- 3. Dynamic Outer Sweep Arc ---
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    final rect = Rect.fromCircle(center: center, radius: outerRadius);

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [color1, color2, color1],
        stops: const [0.0, 0.5, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, sweepPaint);

    // --- 4. 8 Precision Compass & Gyro Tick Marks (every 45 degrees) ---
    final tickPaint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF475569))
          .withValues(alpha: 0.40 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (int i = 0; i < 8; i++) {
      final angle = i * (math.pi / 4);
      final isMajor = i % 2 == 0;
      final tickLength = isMajor ? 5.5 : 3.0;

      final tickStart = Offset(
        center.dx + (outerRadius - tickLength) * math.cos(angle),
        center.dy + (outerRadius - tickLength) * math.sin(angle),
      );
      final tickEnd = Offset(
        center.dx + (outerRadius + 2.0) * math.cos(angle),
        center.dy + (outerRadius + 2.0) * math.sin(angle),
      );
      canvas.drawLine(tickStart, tickEnd, tickPaint);
    }

    // --- 5. Leading Celestial Spark Node with trailing micro-halo ---
    if (progress > 0.04 && progress < 0.99) {
      final currentAngle = -math.pi / 2 + sweepAngle;
      final sparkCenter = Offset(
        center.dx + outerRadius * math.cos(currentAngle),
        center.dy + outerRadius * math.sin(currentAngle),
      );

      // Trailing subtle tail arc
      final tailPaint = Paint()
        ..color = sparkColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.6
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, currentAngle - 0.25, 0.25, false, tailPaint);

      // Spark glow halo
      final sparkGlow = Paint()
        ..color = sparkColor.withValues(alpha: 0.75)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(sparkCenter, 4.5, sparkGlow);

      // Spark bright white core
      final sparkCore = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(sparkCenter, 2.0, sparkCore);
    }
  }

  @override
  bool shouldRepaint(covariant _TaskoraGyroscopeRingsPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.floatAngle != floatAngle ||
        oldDelegate.color1 != color1 ||
        oldDelegate.color2 != color2 ||
        oldDelegate.sparkColor != sparkColor;
  }
}

/// CustomPainter drawing the checkmark path with a glowing laser spark head
/// and trailing particle wake.
class _TaskoraModernCheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color sparkColor;
  final double strokeWidth;

  const _TaskoraModernCheckmarkPainter({
    required this.progress,
    required this.color,
    required this.sparkColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Proportional coordinates for dynamic victory checkmark
    final path = Path();
    path.moveTo(size.width * 0.16, size.height * 0.52);
    path.lineTo(size.width * 0.42, size.height * 0.78);
    path.lineTo(size.width * 0.86, size.height * 0.22);

    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) return;

    final metric = pathMetrics.first;
    final clampedProgress = progress.clamp(0.0, 1.0);
    final extractLength = metric.length * clampedProgress;
    final animatedPath = metric.extractPath(0.0, extractLength);

    // Draw main stroke
    canvas.drawPath(animatedPath, paint);

    // Draw leading laser spark particle at the stroke tip with trailing wake
    if (clampedProgress > 0.02 && clampedProgress < 0.99) {
      final tangent = metric.getTangentForOffset(extractLength);
      if (tangent != null) {
        final tip = tangent.position;

        // Spark outer glow
        final sparkGlow = Paint()
          ..color = sparkColor.withValues(alpha: 0.75)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(tip, strokeWidth * 1.6, sparkGlow);

        // Spark center white core
        final sparkCore = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(tip, strokeWidth * 0.75, sparkCore);

        // Trailing wake micro-particles
        if (extractLength > strokeWidth * 2.0) {
          final wakeTangent = metric.getTangentForOffset(extractLength - strokeWidth * 1.8);
          if (wakeTangent != null) {
            final wakePaint = Paint()
              ..color = sparkColor.withValues(alpha: 0.45)
              ..style = PaintingStyle.fill;
            canvas.drawCircle(wakeTangent.position, strokeWidth * 0.5, wakePaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TaskoraModernCheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.sparkColor != sparkColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
