import 'package:flutter/services.dart';

/// Tactile micro-interaction feedback utility for Taskora.
class HapticFeedbackUtil {
  HapticFeedbackUtil._();

  /// Global master switch for haptic feedback.
  static bool isEnabled = true;

  /// Subtle click for chips, checkboxes, small buttons.
  static Future<void> light() async {
    if (!isEnabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Medium bump for modals, drag actions, tab changes.
  static Future<void> medium() async {
    if (!isEnabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Distinct click for selection, picker wheels, date changes.
  static Future<void> selection() async {
    if (!isEnabled) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Celebratory double pulse when completing a task or milestone.
  static Future<void> taskCompleted() async {
    if (!isEnabled) return;
    try {
      await HapticFeedback.mediumImpact();
      await Future<void>.delayed(const Duration(milliseconds: 90));
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Warning or delete action feedback.
  static Future<void> heavy() async {
    if (!isEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}
