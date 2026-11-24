import 'package:flutter/material.dart';

/// Modern, high-aesthetic color palette for Taskora.
/// Engineered around a vibrant "Electric Iris & Bioluminescent Cyan" brand identity,
/// rich velvet-obsidian surfaces in Dark Mode, and crisp porcelain-pearl surfaces in Light Mode.
class AppColors {
  AppColors._();

  // Primary - Electric Iris Scale (Modern, Luminous, Confident)
  static const Color primary = Color(0xFF6366F1); // Electric Iris 500
  static const Color primaryLight = Color(0xFF818CF8); // Luminous Periwinkle 400
  static const Color primaryDark = Color(0xFF4F46E5); // Deep Iris 600
  static const Color primaryDeep = Color(0xFF4338CA); // Deep Royal Amethyst 700
  static const Color primaryContainerLight = Color(0xFFEEF2FF); // Soft Iris Tint 50
  static const Color primaryContainerDark = Color(0xFF1E1B4B); // Deep Obsidian Iris 950

  // Secondary - Bioluminescent Electric Cyan / Aqua Scale
  static const Color secondary = Color(0xFF06B6D4); // Electric Cyan 500
  static const Color secondaryLight = Color(0xFF22D3EE); // Luminous Aqua 400
  static const Color secondaryDark = Color(0xFF0891B2); // Deep Marine Cyan 600
  static const Color secondaryContainerLight = Color(0xFFECFEFF); // Frost Cyan 50
  static const Color secondaryContainerDark = Color(0xFF164E63); // Deep Abyss Cyan 900

  // Vibrant Accents
  static const Color accentCoral = Color(0xFFFF3366); // Neon Rose / Coral
  static const Color accentAmber = Color(0xFFFF9500); // Solar Amber / Sunset
  static const Color accentEmerald = Color(0xFF10B981); // Crisp Mint Emerald
  static const Color accentPurple = Color(0xFFA855F7); // Electric Violet

  // Semantic Task Priority Indicators (High-energy & distinctive)
  static const Color priorityUrgent = Color(0xFFFF3366); // Neon Crimson / Rose
  static const Color priorityUrgentContainer = Color(0xFFFFE4E6);
  static const Color priorityHigh = Color(0xFFFF9500); // Solar Amber
  static const Color priorityHighContainer = Color(0xFFFFF7ED);
  static const Color priorityMedium = Color(0xFF3B82F6); // Electric Azure
  static const Color priorityMediumContainer = Color(0xFFEFF6FF);
  static const Color priorityLow = Color(0xFF10B981); // Crisp Mint Emerald
  static const Color priorityLowContainer = Color(0xFFECFDF5);

  // Category Colors (Harmonious & Distinctive)
  static const Color categoryWork = Color(0xFF6366F1); // Electric Iris
  static const Color categoryPersonal = Color(0xFF10B981); // Mint Emerald
  static const Color categoryHealth = Color(0xFFFF3366); // Neon Rose
  static const Color categoryStudy = Color(0xFFFF9500); // Solar Amber
  static const Color categoryFinance = Color(0xFF06B6D4); // Bioluminescent Cyan

  // Light Mode Surfaces (Pristine Porcelain & Pearl Slate)
  static const Color lightBackground = Color(0xFFF8FAFC); // Clean Pearl Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure Crisp White
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9); // Clean Frost Neutral
  static const Color lightCardBorder = Color(0xFFE2E8F0); // Platinum Border
  static const Color lightTextPrimary = Color(0xFF0F172A); // Deep Slate-Black
  static const Color lightTextSecondary = Color(0xFF475569); // Refined Graphite
  static const Color lightTextTertiary = Color(0xFF94A3B8); // Muted Silver
  static const Color lightDivider = Color(0xFFE2E8F0);

  // Dark Mode Surfaces (Deep Velvet Obsidian & Jewel Glass)
  static const Color darkBackground = Color(0xFF090A10); // True Deep Obsidian Space
  static const Color darkSurface = Color(0xFF121422); // Velvet Obsidian Card
  static const Color darkSurfaceVariant = Color(0xFF1B1E32); // Luminous Midnight Container
  static const Color darkCardBorder = Color(0xFF262A46); // Jewel-Cut Subtle Glow Border
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Starlight White
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Luminous Silver Slate
  static const Color darkTextTertiary = Color(0xFF64748B); // Muted Cosmic Dust
  static const Color darkDivider = Color(0xFF1E2238);

  // Vibrant Atmospheric Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF6366F1), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient focusTimerGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient celebrationGradient = LinearGradient(
    colors: [Color(0xFFFF3366), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient ambientGlowLight = RadialGradient(
    center: Alignment(0.0, -0.2),
    radius: 0.85,
    colors: [
      Color(0x286366F1), // Soft Iris Aura
      Color(0x1006B6D4), // Soft Cyan Aura
      Colors.transparent,
    ],
    stops: [0.0, 0.55, 1.0],
  );

  static const RadialGradient ambientGlowDark = RadialGradient(
    center: Alignment(0.0, -0.2),
    radius: 0.85,
    colors: [
      Color(0x386366F1), // Deep Iris Aura
      Color(0x1C06B6D4), // Cyan Aurora
      Colors.transparent,
    ],
    stops: [0.0, 0.6, 1.0],
  );
}
