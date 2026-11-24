import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/theme_provider.dart';

/// Ambient breathing Aurora Mesh background with floating star dust for the splash screen.
/// Produces a modern, spatial aesthetic that dynamically adapts to the active [AppThemePalette]
/// and Light/Dark brightness.
class AmbientPulseBackground extends StatefulWidget {
  final Widget child;
  final AppThemePalette palette;

  const AmbientPulseBackground({
    super.key,
    required this.child,
    required this.palette,
  });

  @override
  State<AmbientPulseBackground> createState() => _AmbientPulseBackgroundState();
}

class _AmbientPulseBackgroundState extends State<AmbientPulseBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _auroraController;

  // Deterministic floating particles for ambient celestial depth
  static final List<_DustParticle> _particles = List.generate(32, (i) {
    final rand = math.Random(i * 47 + 19);
    return _DustParticle(
      x: rand.nextDouble(),
      y: rand.nextDouble(),
      radius: 1.0 + rand.nextDouble() * 2.2,
      speed: 0.12 + rand.nextDouble() * 0.38,
      baseOpacity: 0.15 + rand.nextDouble() * 0.35,
      twinkleOffset: rand.nextDouble() * 2 * math.pi,
    );
  });

  @override
  void initState() {
    super.initState();
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    )..repeat();
  }

  @override
  void dispose() {
    _auroraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF080911)
        : const Color(0xFFF8FAFC);

    final primary = widget.palette.primaryColor;
    final secondary = widget.palette.secondaryColor;
    final primaryLight = widget.palette.primaryLightColor;

    return ColoredBox(
      color: backgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Subtle architectural grid background for modern spatial feel
          CustomPaint(
            size: Size.infinite,
            painter: _SpatialGridPainter(
              gridColor: isDark
                  ? Colors.white.withValues(alpha: 0.025)
                  : Colors.black.withValues(alpha: 0.035),
            ),
          ),

          // Animated Aurora Mesh Gradients synchronized with theme palette
          AnimatedBuilder(
            animation: _auroraController,
            builder: (context, _) {
              final t = _auroraController.value * 2 * math.pi;
              final orb1OffsetX = math.sin(t) * 55;
              final orb1OffsetY = math.cos(t * 0.8) * 45;
              final orb2OffsetX = math.cos(t + math.pi) * 50;
              final orb2OffsetY = math.sin(t * 0.9 + math.pi) * 40;
              final orb3OffsetX = math.sin(t * 1.2) * 35;
              final orb3OffsetY = math.cos(t * 1.1) * 35;

              final orb1Color = isDark
                  ? primary.withValues(alpha: 0.28)
                  : primary.withValues(alpha: 0.16);
              final orb2Color = isDark
                  ? secondary.withValues(alpha: 0.22)
                  : secondary.withValues(alpha: 0.13);
              final orb3Color = isDark
                  ? primaryLight.withValues(alpha: 0.14)
                  : primaryLight.withValues(alpha: 0.09);

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Top-Right Aurora Orb
                  Positioned(
                    top: -70 + orb1OffsetY,
                    right: -70 + orb1OffsetX,
                    child: Container(
                      width: 380,
                      height: 380,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            orb1Color,
                            orb1Color.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.72],
                        ),
                      ),
                    ),
                  ),

                  // Bottom-Left Aurora Orb
                  Positioned(
                    bottom: -90 + orb2OffsetY,
                    left: -90 + orb2OffsetX,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            orb2Color,
                            orb2Color.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.72],
                        ),
                      ),
                    ),
                  ),

                  // Center Floating Ambient Aura Orb
                  Positioned(
                    top: 240 + orb3OffsetY,
                    left: 40 + orb3OffsetX,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            orb3Color,
                            orb3Color.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.70],
                        ),
                      ),
                    ),
                  ),

                  // Ambient Dust Starlight Particles
                  CustomPaint(
                    size: Size.infinite,
                    painter: _DustParticlesPainter(
                      progress: _auroraController.value,
                      particles: _particles,
                      particleColor: isDark
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              );
            },
          ),

          // Main foreground
          widget.child,
        ],
      ),
    );
  }
}

class _DustParticle {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double baseOpacity;
  final double twinkleOffset;

  const _DustParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.baseOpacity,
    required this.twinkleOffset,
  });
}

class _DustParticlesPainter extends CustomPainter {
  final double progress;
  final List<_DustParticle> particles;
  final Color particleColor;

  _DustParticlesPainter({
    required this.progress,
    required this.particles,
    required this.particleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      // Particles drift gently upward and wrap seamlessly
      final currentY = ((p.y - progress * p.speed) % 1.0) * size.height;
      final currentX = (p.x * size.width) + math.sin(progress * 2 * math.pi + p.twinkleOffset) * 8.0;

      // Twinkle pulsation
      final twinkle = (math.sin(progress * 4 * math.pi + p.twinkleOffset) + 1.0) / 2.0;
      final opacity = (p.baseOpacity * (0.6 + 0.4 * twinkle)).clamp(0.0, 1.0);

      paint.color = particleColor.withValues(alpha: opacity);
      canvas.drawCircle(Offset(currentX, currentY), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DustParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _SpatialGridPainter extends CustomPainter {
  final Color gridColor;

  const _SpatialGridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const spacing = 48.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpatialGridPainter oldDelegate) => false;
}
