import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/theme_provider.dart';

/// Lightweight, high-performance canvas particle system for task celebrations.
class ConfettiController extends ChangeNotifier {
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  void play() {
    _isPlaying = true;
    notifyListeners();
  }

  void stop() {
    _isPlaying = false;
    notifyListeners();
  }
}

class ConfettiCelebrationOverlay extends StatefulWidget {
  final ConfettiController controller;
  final Widget child;
  final AppThemePalette palette;

  const ConfettiCelebrationOverlay({
    super.key,
    required this.controller,
    required this.child,
    required this.palette,
  });

  @override
  State<ConfettiCelebrationOverlay> createState() =>
      _ConfettiCelebrationOverlayState();
}

class _ConfettiCelebrationOverlayState extends State<ConfettiCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..addListener(() {
        if (mounted) setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.controller.stop();
        }
      });

    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    _animController.dispose();
    super.dispose();
  }

  void _onControllerChange() {
    if (widget.controller.isPlaying) {
      _spawnParticles();
      _animController.forward(from: 0.0);
    }
  }

  void _spawnParticles() {
    _particles.clear();
    final paletteColors = [
      widget.palette.primaryColor,
      widget.palette.primaryLightColor,
      widget.palette.secondaryColor,
      widget.palette.secondaryLightColor,
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFF6584), // Coral Pink
      const Color(0xFF38BDF8), // Sky Blue
    ];

    for (int i = 0; i < 65; i++) {
      // Particles burst upward and outwards from top-center / screen width
      final angle = -math.pi / 2 + (_random.nextDouble() - 0.5) * (math.pi * 0.85);
      final speed = 250.0 + _random.nextDouble() * 450.0;
      final color = paletteColors[_random.nextInt(paletteColors.length)];

      _particles.add(
        _ConfettiParticle(
          x: 0.5 + (_random.nextDouble() - 0.5) * 0.4,
          y: 0.45,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          size: 7.0 + _random.nextDouble() * 7.0,
          color: color,
          rotation: _random.nextDouble() * math.pi * 2,
          rotationSpeed: (_random.nextDouble() - 0.5) * 14.0,
          shape: _random.nextInt(3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_animController.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _animController.value,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  final double size;
  final Color color;
  double rotation;
  final double rotationSpeed;
  final int shape; // 0 = rect, 1 = circle, 2 = diamond

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;

    final dt = progress * 1.8; // Time in seconds
    final gravity = 700.0;
    final airResistance = 0.985;
    final alpha = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final currentVx = p.vx * math.pow(airResistance, dt * 60);
      final currentVy = (p.vy + gravity * dt) * math.pow(airResistance, dt * 60);

      final px = p.x * size.width + (currentVx * dt * 0.4);
      final py = p.y * size.height + (currentVy * dt * 0.4);
      final rot = p.rotation + (p.rotationSpeed * dt);

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(rot);

      if (p.shape == 0) {
        // Rectangle ribbon
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: p.size * 1.4,
          height: p.size * 0.6,
        );
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), paint);
      } else if (p.shape == 1) {
        // Circle dot
        canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
      } else {
        // Diamond star
        final path = Path()
          ..moveTo(0, -p.size * 0.7)
          ..lineTo(p.size * 0.5, 0)
          ..lineTo(0, p.size * 0.7)
          ..lineTo(-p.size * 0.5, 0)
          ..close();
        canvas.drawPath(path, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
