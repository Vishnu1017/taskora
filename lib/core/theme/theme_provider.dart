import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Provider for SharedPreferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
});

/// Available high-aesthetic, modern unique color palettes for Taskora.
enum AppThemePalette {
  neonLime,
  sunsetMirage,
  obsidianGold,
  nordicGlacier,
  zenMatcha,
  electricViolet,
  cyberOcean,
  monochromeStealth,
  crimsonEclipse,
  desertDune,
  auroraBorealis,
  bubblegumCyber,
  amethystHaze,
  matrixEmerald;

  String get displayName => switch (this) {
    AppThemePalette.neonLime => 'Neon Lime',
    AppThemePalette.sunsetMirage => 'Sunset Mirage',
    AppThemePalette.obsidianGold => 'Obsidian Gold',
    AppThemePalette.nordicGlacier => 'Nordic Glacier',
    AppThemePalette.zenMatcha => 'Zen Matcha',
    AppThemePalette.electricViolet => 'Electric Violet',
    AppThemePalette.cyberOcean => 'Cyber Ocean',
    AppThemePalette.monochromeStealth => 'Stealth Titanium',
    AppThemePalette.crimsonEclipse => 'Crimson Eclipse',
    AppThemePalette.desertDune => 'Desert Dune',
    AppThemePalette.auroraBorealis => 'Aurora Borealis',
    AppThemePalette.bubblegumCyber => 'Bubblegum Cyber',
    AppThemePalette.amethystHaze => 'Amethyst Haze',
    AppThemePalette.matrixEmerald => 'Matrix Emerald',
  };

  String get subtitle => switch (this) {
    AppThemePalette.neonLime => 'Acid Lime & Cyber Carbon',
    AppThemePalette.sunsetMirage => 'Neon Peach & Aurora Violet',
    AppThemePalette.obsidianGold => 'Champagne Gold & Solar Amber',
    AppThemePalette.nordicGlacier => 'Glacier Ice & Polar Mint',
    AppThemePalette.zenMatcha => 'Matcha Teal & Warm Terracotta',
    AppThemePalette.electricViolet => 'Electric Iris & Cyan',
    AppThemePalette.cyberOcean => 'Bioluminescent Cyan & Azure',
    AppThemePalette.monochromeStealth => 'Titanium Slate & Crimson Laser',
    AppThemePalette.crimsonEclipse => 'Tokyo Crimson & Neon Violet',
    AppThemePalette.desertDune => 'Mojave Amber & Terracotta',
    AppThemePalette.auroraBorealis => 'Polar Emerald & Cosmic Indigo',
    AppThemePalette.bubblegumCyber => 'Vaporwave Pink & Cyan Spark',
    AppThemePalette.amethystHaze => 'Royal Amethyst & Mystic Orchid',
    AppThemePalette.matrixEmerald => 'Phosphor Terminal & Cyber Jade',
  };

  Color get primaryColor => switch (this) {
    AppThemePalette.neonLime => const Color(0xFF84CC16), // Acid Lime 500
    AppThemePalette.sunsetMirage => const Color(0xFFFF5E7E), // Neon Peach
    AppThemePalette.obsidianGold => const Color(0xFFE5A93C), // Champagne Gold
    AppThemePalette.nordicGlacier => const Color(0xFF38BDF8), // Glacier Ice
    AppThemePalette.zenMatcha => const Color(0xFF14B8A6), // Matcha Teal
    AppThemePalette.electricViolet => const Color(0xFF6366F1), // Electric Iris
    AppThemePalette.cyberOcean => const Color(0xFF06B6D4), // Electric Cyan
    AppThemePalette.monochromeStealth => const Color(0xFF94A3B8), // Titanium Slate
    AppThemePalette.crimsonEclipse => const Color(0xFFF43F5E), // Neo Crimson 500
    AppThemePalette.desertDune => const Color(0xFFF59E0B), // Mojave Amber 500
    AppThemePalette.auroraBorealis => const Color(0xFF10B981), // Emerald 500
    AppThemePalette.bubblegumCyber => const Color(0xFFEC4899), // Vaporwave Pink 500
    AppThemePalette.amethystHaze => const Color(0xFF8B5CF6), // Royal Amethyst 500
    AppThemePalette.matrixEmerald => const Color(0xFF22C55E), // Phosphor Green 500
  };

  Color get primaryLightColor => switch (this) {
    AppThemePalette.neonLime => const Color(0xFFA3E635), // Hyper Lime 400
    AppThemePalette.sunsetMirage => const Color(0xFFFFA4B6),
    AppThemePalette.obsidianGold => const Color(0xFFFBBF24), // Solar Amber
    AppThemePalette.nordicGlacier => const Color(0xFF7DD3FC),
    AppThemePalette.zenMatcha => const Color(0xFF2DD4BF),
    AppThemePalette.electricViolet => const Color(0xFF818CF8),
    AppThemePalette.cyberOcean => const Color(0xFF22D3EE),
    AppThemePalette.monochromeStealth => const Color(0xFFCBD5E1),
    AppThemePalette.crimsonEclipse => const Color(0xFFFB7185),
    AppThemePalette.desertDune => const Color(0xFFFBBF24),
    AppThemePalette.auroraBorealis => const Color(0xFF34D399),
    AppThemePalette.bubblegumCyber => const Color(0xFFF472B6),
    AppThemePalette.amethystHaze => const Color(0xFFA78BFA),
    AppThemePalette.matrixEmerald => const Color(0xFF4ADE80),
  };

  Color get primaryDarkColor => switch (this) {
    AppThemePalette.neonLime => const Color(0xFF65A30D), // Deep Lime 600
    AppThemePalette.sunsetMirage => const Color(0xFFE11D48),
    AppThemePalette.obsidianGold => const Color(0xFFB45309),
    AppThemePalette.nordicGlacier => const Color(0xFF0284C7),
    AppThemePalette.zenMatcha => const Color(0xFF0F766E),
    AppThemePalette.electricViolet => const Color(0xFF4F46E5),
    AppThemePalette.cyberOcean => const Color(0xFF0891B2),
    AppThemePalette.monochromeStealth => const Color(0xFF475569),
    AppThemePalette.crimsonEclipse => const Color(0xFFBE123C),
    AppThemePalette.desertDune => const Color(0xFFB45309),
    AppThemePalette.auroraBorealis => const Color(0xFF047857),
    AppThemePalette.bubblegumCyber => const Color(0xFFBE185D),
    AppThemePalette.amethystHaze => const Color(0xFF6D28D9),
    AppThemePalette.matrixEmerald => const Color(0xFF15803D),
  };

  Color get primaryContainerLightColor => switch (this) {
    AppThemePalette.neonLime => const Color(0xFFF7FEE7), // Lime 50
    AppThemePalette.sunsetMirage => const Color(0xFFFFF1F4),
    AppThemePalette.obsidianGold => const Color(0xFFFEF3C7),
    AppThemePalette.nordicGlacier => const Color(0xFFF0F9FF),
    AppThemePalette.zenMatcha => const Color(0xFFF0FDFA),
    AppThemePalette.electricViolet => const Color(0xFFEEF2FF),
    AppThemePalette.cyberOcean => const Color(0xFFECFEFF),
    AppThemePalette.monochromeStealth => const Color(0xFFF1F5F9),
    AppThemePalette.crimsonEclipse => const Color(0xFFFFF1F2),
    AppThemePalette.desertDune => const Color(0xFFFFFBEB),
    AppThemePalette.auroraBorealis => const Color(0xFFECFDF5),
    AppThemePalette.bubblegumCyber => const Color(0xFFFDF2F8),
    AppThemePalette.amethystHaze => const Color(0xFFF5F3FF),
    AppThemePalette.matrixEmerald => const Color(0xFFF0FDF4),
  };

  Color get primaryContainerDarkColor => switch (this) {
    AppThemePalette.neonLime => const Color(0xFF1A2E05), // Deep Cyber Olive 950
    AppThemePalette.sunsetMirage => const Color(0xFF4C0519),
    AppThemePalette.obsidianGold => const Color(0xFF3A2402),
    AppThemePalette.nordicGlacier => const Color(0xFF082F49),
    AppThemePalette.zenMatcha => const Color(0xFF042F2E),
    AppThemePalette.electricViolet => const Color(0xFF1E1B4B),
    AppThemePalette.cyberOcean => const Color(0xFF164E63),
    AppThemePalette.monochromeStealth => const Color(0xFF1E293B),
    AppThemePalette.crimsonEclipse => const Color(0xFF4C0519),
    AppThemePalette.desertDune => const Color(0xFF451A03),
    AppThemePalette.auroraBorealis => const Color(0xFF022C22),
    AppThemePalette.bubblegumCyber => const Color(0xFF500724),
    AppThemePalette.amethystHaze => const Color(0xFF2E1065),
    AppThemePalette.matrixEmerald => const Color(0xFF052E16),
  };

  Color get secondaryColor => switch (this) {
    AppThemePalette.neonLime => const Color(0xFF06B6D4), // Cyan
    AppThemePalette.sunsetMirage => const Color(0xFFA855F7), // Aurora Violet
    AppThemePalette.obsidianGold => const Color(0xFF38BDF8), // Ice Sky
    AppThemePalette.nordicGlacier => const Color(0xFF2DD4BF), // Polar Mint
    AppThemePalette.zenMatcha => const Color(0xFFF97316), // Terracotta
    AppThemePalette.electricViolet => const Color(0xFF06B6D4), // Cyan
    AppThemePalette.cyberOcean => const Color(0xFF3B82F6), // Azure
    AppThemePalette.monochromeStealth => const Color(0xFFFF3366), // Crimson Laser
    AppThemePalette.crimsonEclipse => const Color(0xFF8B5CF6), // Neon Violet 500
    AppThemePalette.desertDune => const Color(0xFFEA580C), // Terracotta 600
    AppThemePalette.auroraBorealis => const Color(0xFF6366F1), // Cosmic Indigo 500
    AppThemePalette.bubblegumCyber => const Color(0xFF06B6D4), // Cyan Spark 500
    AppThemePalette.amethystHaze => const Color(0xFFD946EF), // Mystic Orchid 500
    AppThemePalette.matrixEmerald => const Color(0xFF14B8A6), // Cyber Jade 500
  };

  Color get secondaryLightColor => switch (this) {
    AppThemePalette.neonLime => const Color(0xFF22D3EE),
    AppThemePalette.sunsetMirage => const Color(0xFFC084FC),
    AppThemePalette.obsidianGold => const Color(0xFF7DD3FC),
    AppThemePalette.nordicGlacier => const Color(0xFF5EEAD4),
    AppThemePalette.zenMatcha => const Color(0xFFFB923C),
    AppThemePalette.electricViolet => const Color(0xFF22D3EE),
    AppThemePalette.cyberOcean => const Color(0xFF60A5FA),
    AppThemePalette.monochromeStealth => const Color(0xFFFF6B8B),
    AppThemePalette.crimsonEclipse => const Color(0xFFA78BFA),
    AppThemePalette.desertDune => const Color(0xFFFB923C),
    AppThemePalette.auroraBorealis => const Color(0xFF818CF8),
    AppThemePalette.bubblegumCyber => const Color(0xFF22D3EE),
    AppThemePalette.amethystHaze => const Color(0xFFE879F9),
    AppThemePalette.matrixEmerald => const Color(0xFF2DD4BF),
  };

  Color get secondaryContainerLightColor => switch (this) {
    AppThemePalette.neonLime => const Color(0xFFECFEFF),
    AppThemePalette.sunsetMirage => const Color(0xFFFAF5FF),
    AppThemePalette.obsidianGold => const Color(0xFFF0F9FF),
    AppThemePalette.nordicGlacier => const Color(0xFFF0FDFA),
    AppThemePalette.zenMatcha => const Color(0xFFFFF7ED),
    AppThemePalette.electricViolet => const Color(0xFFECFEFF),
    AppThemePalette.cyberOcean => const Color(0xFFEFF6FF),
    AppThemePalette.monochromeStealth => const Color(0xFFFFF1F2),
    AppThemePalette.crimsonEclipse => const Color(0xFFF5F3FF),
    AppThemePalette.desertDune => const Color(0xFFFFF7ED),
    AppThemePalette.auroraBorealis => const Color(0xFFEEF2FF),
    AppThemePalette.bubblegumCyber => const Color(0xFFECFEFF),
    AppThemePalette.amethystHaze => const Color(0xFFFDF4FF),
    AppThemePalette.matrixEmerald => const Color(0xFFF0FDFA),
  };

  Color get secondaryContainerDarkColor => switch (this) {
    AppThemePalette.neonLime => const Color(0xFF164E63),
    AppThemePalette.sunsetMirage => const Color(0xFF3B0764),
    AppThemePalette.obsidianGold => const Color(0xFF0C4A6E),
    AppThemePalette.nordicGlacier => const Color(0xFF134E4A),
    AppThemePalette.zenMatcha => const Color(0xFF431407),
    AppThemePalette.electricViolet => const Color(0xFF164E63),
    AppThemePalette.cyberOcean => const Color(0xFF1E3A8A),
    AppThemePalette.monochromeStealth => const Color(0xFF4C0519),
    AppThemePalette.crimsonEclipse => const Color(0xFF2E1065),
    AppThemePalette.desertDune => const Color(0xFF431407),
    AppThemePalette.auroraBorealis => const Color(0xFF1E1B4B),
    AppThemePalette.bubblegumCyber => const Color(0xFF164E63),
    AppThemePalette.amethystHaze => const Color(0xFF4A044E),
    AppThemePalette.matrixEmerald => const Color(0xFF042F2E),
  };

  LinearGradient get gradient => switch (this) {
    AppThemePalette.neonLime => const LinearGradient(
      colors: [Color(0xFF65A30D), Color(0xFF84CC16), Color(0xFF06B6D4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    AppThemePalette.sunsetMirage => const LinearGradient(
      colors: [Color(0xFFFF5E7E), Color(0xFFF59E0B), Color(0xFFA855F7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    AppThemePalette.obsidianGold => const LinearGradient(
      colors: [Color(0xFFB45309), Color(0xFFE5A93C), Color(0xFFFDE68A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    AppThemePalette.nordicGlacier => const LinearGradient(
      colors: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFF2DD4BF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    AppThemePalette.zenMatcha => const LinearGradient(
      colors: [Color(0xFF0F766E), Color(0xFF14B8A6), Color(0xFFFB923C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    AppThemePalette.electricViolet => const LinearGradient(
      colors: [Color(0xFF7C3AED), Color(0xFF6366F1), Color(0xFF06B6D4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    AppThemePalette.cyberOcean => const LinearGradient(
      colors: [Color(0xFF0891B2), Color(0xFF06B6D4), Color(0xFF38BDF8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    AppThemePalette.monochromeStealth => const LinearGradient(
      colors: [Color(0xFF334155), Color(0xFF64748B), Color(0xFFFF3366)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    AppThemePalette.crimsonEclipse => const LinearGradient(
      colors: [Color(0xFFBE123C), Color(0xFFF43F5E), Color(0xFF8B5CF6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    AppThemePalette.desertDune => const LinearGradient(
      colors: [Color(0xFFB45309), Color(0xFFF59E0B), Color(0xFFEA580C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    AppThemePalette.auroraBorealis => const LinearGradient(
      colors: [Color(0xFF047857), Color(0xFF10B981), Color(0xFF6366F1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    AppThemePalette.bubblegumCyber => const LinearGradient(
      colors: [Color(0xFFEC4899), Color(0xFFA855F7), Color(0xFF06B6D4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    AppThemePalette.amethystHaze => const LinearGradient(
      colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6), Color(0xFFD946EF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    AppThemePalette.matrixEmerald => const LinearGradient(
      colors: [Color(0xFF15803D), Color(0xFF22C55E), Color(0xFF14B8A6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  };

  static AppThemePalette fromString(String? value) {
    switch (value) {
      case 'neonLime':
        return AppThemePalette.neonLime;
      case 'sunsetMirage':
        return AppThemePalette.sunsetMirage;
      case 'obsidianGold':
        return AppThemePalette.obsidianGold;
      case 'nordicGlacier':
        return AppThemePalette.nordicGlacier;
      case 'zenMatcha':
        return AppThemePalette.zenMatcha;
      case 'cyberOcean':
        return AppThemePalette.cyberOcean;
      case 'monochromeStealth':
        return AppThemePalette.monochromeStealth;
      case 'electricViolet':
        return AppThemePalette.electricViolet;
      case 'crimsonEclipse':
        return AppThemePalette.crimsonEclipse;
      case 'desertDune':
        return AppThemePalette.desertDune;
      case 'auroraBorealis':
        return AppThemePalette.auroraBorealis;
      case 'bubblegumCyber':
        return AppThemePalette.bubblegumCyber;
      case 'amethystHaze':
        return AppThemePalette.amethystHaze;
      case 'matrixEmerald':
        return AppThemePalette.matrixEmerald;
      default:
        return AppThemePalette.neonLime; // Fresh, modern default!
    }
  }
}

/// State notifier managing dynamic theme mode switching with persistent storage.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeModeNotifier(this._prefs) : super(_loadInitialTheme(_prefs));

  static ThemeMode _loadInitialTheme(SharedPreferences prefs) {
    final savedMode = prefs.getString(AppConstants.keyThemeMode);
    switch (savedMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Update theme mode and save to persistent preferences.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final modeString = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(AppConstants.keyThemeMode, modeString);
  }

  /// Cycles theme through System -> Light -> Dark -> System.
  Future<void> toggleTheme() async {
    final nextMode = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setThemeMode(nextMode);
  }
}

/// Global provider for the theme mode.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return ThemeModeNotifier(prefs);
    });

/// State notifier managing dynamic color palette switching.
class ThemePaletteNotifier extends StateNotifier<AppThemePalette> {
  final SharedPreferences _prefs;

  ThemePaletteNotifier(this._prefs) : super(_loadInitialPalette(_prefs));

  static AppThemePalette _loadInitialPalette(SharedPreferences prefs) {
    final saved = prefs.getString(AppConstants.keyThemePalette);
    return AppThemePalette.fromString(saved);
  }

  Future<void> setPalette(AppThemePalette palette) async {
    state = palette;
    await _prefs.setString(AppConstants.keyThemePalette, palette.name);
  }
}

/// Global provider for the active color palette.
final themePaletteProvider =
    StateNotifierProvider<ThemePaletteNotifier, AppThemePalette>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return ThemePaletteNotifier(prefs);
    });
