import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/haptic_feedback_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistent SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  HapticFeedbackUtil.isEnabled =
      prefs.getBool(AppConstants.keyHapticsEnabled) ?? true;

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const TaskoraApp(),
    ),
  );
}

/// The root Taskora application widget with accessible textScaler clamping.
class TaskoraApp extends ConsumerWidget {
  const TaskoraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themePalette = ref.watch(themePaletteProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.getTheme(Brightness.light, themePalette),
      darkTheme: AppTheme.getTheme(Brightness.dark, themePalette),
      routerConfig: AppRouter.router,
      builder: (context, child) {
        // Enforce safe accessible text scaling bounds so large font settings
        // never clip or overflow cards, dialogs, or navigation rails.
        final mediaQuery = MediaQuery.of(context);
        final clampedScaler = mediaQuery.textScaler.clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.35,
        );
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: clampedScaler),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
