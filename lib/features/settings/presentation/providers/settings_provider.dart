import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/haptic_feedback_util.dart';

/// State notifier managing user haptic feedback preferences with persistent storage.
class HapticsNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  HapticsNotifier(this._prefs) : super(_loadInitialState(_prefs)) {
    HapticFeedbackUtil.isEnabled = state;
  }

  static bool _loadInitialState(SharedPreferences prefs) {
    return prefs.getBool(AppConstants.keyHapticsEnabled) ?? true;
  }

  /// Update haptic feedback preference and persist to SharedPreferences.
  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    HapticFeedbackUtil.isEnabled = enabled;
    await _prefs.setBool(AppConstants.keyHapticsEnabled, enabled);
    if (enabled) {
      await HapticFeedbackUtil.selection();
    }
  }

  /// Toggles haptic feedback state.
  Future<void> toggle() => setEnabled(!state);
}

/// Global provider for the haptics preference.
final hapticsEnabledProvider =
    StateNotifierProvider<HapticsNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HapticsNotifier(prefs);
});
