import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/haptic_feedback_util.dart';
import 'widgets/ambient_pulse_background.dart';
import 'widgets/animated_taskora_emblem.dart';

/// Modern Signature Animated Splash Screen for Taskora.
/// Features:
/// 1. Ambient breathing Aurora Mesh background with floating starlight dust.
/// 2. Kinetic Quantum Gyroscope Emblem with 3D Zero-G perspective floating & touch parallax.
/// 3. Crystalline Specular Light Sheen sweep across the prism face.
/// 4. Tactile dual-stage haptics and concentric resonance shockwaves.
/// 5. Cinematic kinetic typography with aperture expanding letter-spacing.
/// 6. Frosted live status capsule with real-time stage transitions & percentage counter.
/// 7. Fully reactive to the active [AppThemePalette].
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final AnimationController _floatController;

  late final Animation<double> _emblemScaleAnimation;
  late final Animation<double> _ringProgressAnimation;
  late final Animation<double> _checkmarkStrokeAnimation;
  late final Animation<double> _shimmerAnimation;
  late final Animation<double> _rippleAnimation;
  late final Animation<double> _textOpacityAnimation;
  late final Animation<Offset> _textSlideAnimation;
  late final Animation<double> _letterSpacingAnimation;
  late final Animation<double> _glowPulseAnimation;
  late final Animation<double> _statusPillOpacityAnimation;
  late final Animation<double> _exitScaleAnimation;

  bool _hasTriggeredRingHaptic = false;
  bool _hasTriggeredCheckmarkHaptic = false;
  Offset _touchOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _setupAnimationSequences();
    _initializeAppAndNavigate();
  }

  void _setupAnimationSequences() {
    // Primary Stage Choreography Controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.splashMinDurationMs),
    );

    // Continuous Zero-G Floating Tilt Controller
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat();

    // 1. Emblem Scale & Elastic Entrance (0.00 -> 0.38)
    _emblemScaleAnimation = Tween<double>(begin: 0.20, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.00, 0.38, curve: Curves.easeOutBack),
      ),
    );

    // 2. Gyroscope Rings Sweep & Alignment (0.10 -> 0.60)
    _ringProgressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.10, 0.60, curve: Curves.easeInOutCubic),
      ),
    );

    // 3. Laser Checkmark Stroke-Draw (0.30 -> 0.70)
    _checkmarkStrokeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.30, 0.70, curve: Curves.easeInOutCubic),
      ),
    );

    // 4. Crystalline Specular Light Sheen across Prism Face (0.38 -> 0.78)
    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.38, 0.78, curve: Curves.easeInOutCubic),
      ),
    );

    // 5. Dual Resonance Shockwaves on Checkmark Lock (0.68 -> 0.96)
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.68, 0.96, curve: Curves.easeOutCubic),
      ),
    );

    // 6. Brand Wordmark & Tagline Upward Glide (0.42 -> 0.78)
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.42, 0.78, curve: Curves.easeOut),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.28),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.42, 0.78, curve: Curves.easeOutCubic),
      ),
    );

    // Kinetic Expanding Letter-Spacing Aperture Effect (0.45 -> 0.85)
    _letterSpacingAnimation = Tween<double>(begin: 2.5, end: 7.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    // 7. Ambient Neon Glow Pulse (0.48 -> 1.00)
    _glowPulseAnimation = Tween<double>(begin: 0.70, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.48, 1.00, curve: Curves.easeInOutSine),
      ),
    );

    // 8. Bottom Status Capsule Fade (0.52 -> 0.85)
    _statusPillOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.52, 0.85, curve: Curves.easeOut),
      ),
    );

    // 9. Smooth Portal Exit Scale (0.92 -> 1.00)
    _exitScaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.92, 1.00, curve: Curves.easeInCubic),
      ),
    );

    // Dual-Stage Micro Haptic Feedback
    _animationController.addListener(() {
      final value = _animationController.value;

      // Stage 1: Ring Alignment Lock
      if (value >= 0.35 && !_hasTriggeredRingHaptic) {
        _hasTriggeredRingHaptic = true;
        HapticFeedbackUtil.selection();
      }

      // Stage 2: Checkmark Completion Snap
      if (value >= 0.70 && !_hasTriggeredCheckmarkHaptic) {
        _hasTriggeredCheckmarkHaptic = true;
        HapticFeedbackUtil.medium();
      }
    });
  }

  Future<void> _initializeAppAndNavigate() async {
    final animationFuture = _animationController.forward();

    // Initialize notification channels in background
    final initFuture = Future<void>(() async {
      await NotificationService.instance.initialize();
    });

    await Future.wait([animationFuture, initFuture]);

    if (!mounted) return;

    final prefs = ref.read(sharedPreferencesProvider);
    final onboardingCompleted =
        prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;

    if (mounted) {
      if (onboardingCompleted) {
        context.go('/');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  String _getStatusPhase(double progress) {
    if (progress < 0.28) return 'Initializing Workspace';
    if (progress < 0.60) return 'Calibrating Offline Cache';
    if (progress < 0.88) return 'Syncing Task Engine';
    return 'Welcome to Taskora';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themePalette = ref.watch(themePaletteProvider);
    final isDark = theme.brightness == Brightness.dark;
    final isCompact = context.isCompact;
    final emblemSize = isCompact ? 122.0 : 144.0;

    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          final size = MediaQuery.sizeOf(context);
          setState(() {
            _touchOffset = Offset(
              (details.localPosition.dx / size.width - 0.5) * 2.0,
              (details.localPosition.dy / size.height - 0.5) * 2.0,
            );
          });
        },
        onPanEnd: (_) {
          setState(() => _touchOffset = Offset.zero);
        },
        child: AmbientPulseBackground(
          palette: themePalette,
          child: SafeArea(
            child: Stack(
              children: [
                // Center Emblem & Brand Typography
                Center(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _animationController,
                        _floatController,
                      ]),
                      builder: (context, _) {
                        final floatAngle = _floatController.value * 2 * math.pi;
                        final exitScale = _exitScaleAnimation.value;

                        return Transform.scale(
                          scale: exitScale,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.responsiveHorizontalPadding,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 3D Perspective Floating Gyroscope Emblem
                                AnimatedTaskoraEmblem(
                                  scale: _emblemScaleAnimation.value,
                                  checkmarkProgress: _checkmarkStrokeAnimation.value,
                                  ringProgress: _ringProgressAnimation.value,
                                  shimmerProgress: _shimmerAnimation.value,
                                  rippleProgress: _rippleAnimation.value,
                                  glowOpacity: _glowPulseAnimation.value,
                                  floatAngle: floatAngle,
                                  touchOffset: _touchOffset,
                                  palette: themePalette,
                                  size: emblemSize,
                                ),
                                const SizedBox(height: 38.0),

                                // Wordmark and Spatial Tagline
                                FadeTransition(
                                  opacity: _textOpacityAnimation,
                                  child: SlideTransition(
                                    position: _textSlideAnimation,
                                    child: Column(
                                      children: [
                                        // Kinetic Expanding Gradient Brand Title
                                        ShaderMask(
                                          shaderCallback: (bounds) =>
                                              themePalette.gradient.createShader(bounds),
                                          blendMode: BlendMode.srcIn,
                                          child: Text(
                                            AppConstants.appName.toUpperCase(),
                                            style: theme.textTheme.headlineMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing:
                                                      _letterSpacingAnimation.value,
                                                  color: Colors.white,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 12.0),

                                        // Category tagline with dynamic glowing dots
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _buildTaglineDot(themePalette.primaryColor),
                                            const SizedBox(width: 8),
                                            Text(
                                              'ORGANIZE',
                                              style: _taglineStyle(isDark),
                                            ),
                                            const SizedBox(width: 8),
                                            _buildTaglineDot(themePalette.secondaryColor),
                                            const SizedBox(width: 8),
                                            Text(
                                              'FOCUS',
                                              style: _taglineStyle(isDark),
                                            ),
                                            const SizedBox(width: 8),
                                            _buildTaglineDot(themePalette.primaryColor),
                                            const SizedBox(width: 8),
                                            Text(
                                              'ACHIEVE',
                                              style: _taglineStyle(isDark),
                                            ),
                                            const SizedBox(width: 8),
                                            _buildTaglineDot(themePalette.secondaryColor),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Bottom Live Status Capsule & Subtle Loading Indicator
                Positioned(
                  bottom: 28,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, _) {
                      final progress = _animationController.value;
                      final isComplete = progress >= 0.88;
                      final percentage = (progress * 100).clamp(0, 100).toInt();

                      return FadeTransition(
                        opacity: _statusPillOpacityAnimation,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Frosted Glass Status Capsule
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF131728).withValues(alpha: 0.78)
                                          : Colors.white.withValues(alpha: 0.88),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: isDark
                                            ? const Color(0xFF2E3758).withValues(alpha: 0.8)
                                            : const Color(0xFFE2E8F0),
                                        width: 1.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: isDark ? 0.35 : 0.05,
                                          ),
                                          blurRadius: 14,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Pulsing status beacon
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isComplete
                                                ? const Color(0xFF10B981) // Emerald
                                                : themePalette.primaryColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: (isComplete
                                                        ? const Color(0xFF10B981)
                                                        : themePalette.primaryColor)
                                                    .withValues(alpha: 0.75),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 9),
                                        Text(
                                          _getStatusPhase(progress),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.2,
                                            color: isDark
                                                ? const Color(0xFFCBD5E1)
                                                : const Color(0xFF475569),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Micro percentage badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 1.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: themePalette.primaryColor
                                                .withValues(alpha: isDark ? 0.22 : 0.12),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '$percentage%',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: themePalette.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Micro Gradient Track Line
                              SizedBox(
                                width: 120.0,
                                height: 2.8,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2.0),
                                  child: Stack(
                                    children: [
                                      Container(
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: progress,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: themePalette.gradient,
                                            boxShadow: [
                                              BoxShadow(
                                                color: themePalette.primaryColor
                                                    .withValues(alpha: 0.55),
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaglineDot(Color color) {
    return Container(
      width: 4.0,
      height: 4.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.7),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  TextStyle _taglineStyle(bool isDark) {
    return TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.2,
      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
    );
  }
}
