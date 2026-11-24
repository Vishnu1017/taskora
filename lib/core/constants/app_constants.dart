/// Central application constants for Taskora.
class AppConstants {
  AppConstants._();

  // Branding
  static const String appName = 'Taskora';
  static const String appTagline = 'Master Your Time, Flow With Focus';
  static const String appVersion = '1.0.0';

  // Persistence Keys
  static const String keyThemeMode = 'taskora_theme_mode';
  static const String keyThemePalette = 'taskora_theme_palette';
  static const String keyOnboardingCompleted = 'taskora_onboarding_completed';
  static const String keyUserName = 'taskora_user_name';
  static const String keyFirstLaunchTime = 'taskora_first_launch_time';
  static const String keyHapticsEnabled = 'taskora_haptics_enabled';

  // Animation Timings (in milliseconds)
  static const int splashMinDurationMs = 2400;
  static const int pageTransitionDurationMs = 380;
  static const int quickAnimationDurationMs = 200;
  static const int standardAnimationDurationMs = 320;
  static const int celebratoryDurationMs = 600;

  // Layout Defaults
  static const double defaultBorderRadius = 16.0;
  static const double compactBorderRadius = 12.0;
  static const double sheetBorderRadius = 24.0;
  static const double cardElevation = 0.0;
}
