import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskora/core/constants/app_constants.dart';
import 'package:taskora/core/utils/haptic_feedback_util.dart';
import 'package:taskora/features/settings/presentation/providers/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Haptics Settings & Util Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('defaults to enabled on first launch', () {
      final notifier = HapticsNotifier(prefs);
      expect(notifier.state, isTrue);
      expect(HapticFeedbackUtil.isEnabled, isTrue);
    });

    test('toggling updates state, persists key, and syncs HapticFeedbackUtil', () async {
      final notifier = HapticsNotifier(prefs);

      // Disable
      await notifier.setEnabled(false);
      expect(notifier.state, isFalse);
      expect(HapticFeedbackUtil.isEnabled, isFalse);
      expect(prefs.getBool(AppConstants.keyHapticsEnabled), isFalse);

      // Toggle back to True
      await notifier.toggle();
      expect(notifier.state, isTrue);
      expect(HapticFeedbackUtil.isEnabled, isTrue);
      expect(prefs.getBool(AppConstants.keyHapticsEnabled), isTrue);
    });

    test('loads saved disabled state from SharedPreferences', () async {
      await prefs.setBool(AppConstants.keyHapticsEnabled, false);
      final notifier = HapticsNotifier(prefs);

      expect(notifier.state, isFalse);
      expect(HapticFeedbackUtil.isEnabled, isFalse);
    });
  });
}
