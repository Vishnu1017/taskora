import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../tasks/domain/priority_enum.dart';
import '../../../tasks/domain/task_model.dart';
import '../../domain/gamification_models.dart';

const String _keyGamificationData = 'taskora_gamification_stats_v1';

/// Event payload emitted when a task completion yields XP or a milestone badge.
class GamificationRewardEvent {
  final int xpEarned;
  final int newTotalXp;
  final int newLevel;
  final bool leveledUp;
  final ProductivityBadge? unlockedBadge;
  final int currentStreak;

  const GamificationRewardEvent({
    required this.xpEarned,
    required this.newTotalXp,
    required this.newLevel,
    required this.leveledUp,
    this.unlockedBadge,
    required this.currentStreak,
  });
}

/// Global stream/state provider for newly earned celebration events
final latestGamificationRewardProvider =
    StateProvider<GamificationRewardEvent?>((ref) => null);

/// State notifier managing user streaks, XP, level calculations, and badges.
class GamificationNotifier extends StateNotifier<GamificationStats> {
  final SharedPreferences _prefs;

  GamificationNotifier(this._prefs) : super(const GamificationStats()) {
    _loadInitialStats();
  }

  void _loadInitialStats() {
    final rawJson = _prefs.getString(_keyGamificationData);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
        var loaded = GamificationStats.fromJson(decoded);

        // Check if streak was broken (missed more than 1 day)
        if (loaded.lastCompletionDate != null && loaded.currentStreak > 0) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final lastDay = DateTime(
            loaded.lastCompletionDate!.year,
            loaded.lastCompletionDate!.month,
            loaded.lastCompletionDate!.day,
          );
          final daysDiff = today.difference(lastDay).inDays;
          if (daysDiff > 1) {
            // Streak broken, reset current streak but preserve best streak and XP!
            loaded = loaded.copyWith(currentStreak: 0);
            _saveStats(loaded);
          }
        }

        state = loaded;
        return;
      } catch (_) {}
    }

    state = const GamificationStats();
  }

  Future<void> _saveStats(GamificationStats stats) async {
    state = stats;
    final encoded = jsonEncode(stats.toJson());
    await _prefs.setString(_keyGamificationData, encoded);
  }

  /// Calculates XP, streak increment, and badge unlocks upon task completion.
  Future<GamificationRewardEvent> recordTaskCompletion(Task task) async {
    final prevLevel = state.level;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Calculate XP reward
    int xp = 25; // Base XP
    if (task.priority == TaskPriority.urgent ||
        task.priority == TaskPriority.high) {
      xp += 25; // Priority bounty (+50 total)
    }
    if (task.subtasks.isNotEmpty) {
      xp += task.subtasks.length * 5; // Subtasks bonus
    }

    // 2. Calculate Daily Streak
    int newStreak = state.currentStreak;
    int newBestStreak = state.bestStreak;

    if (state.lastCompletionDate == null) {
      newStreak = 1;
    } else {
      final lastDay = DateTime(
        state.lastCompletionDate!.year,
        state.lastCompletionDate!.month,
        state.lastCompletionDate!.day,
      );
      final daysDiff = today.difference(lastDay).inDays;

      if (daysDiff == 0) {
        // Already completed tasks today, maintain current streak
        newStreak = state.currentStreak == 0 ? 1 : state.currentStreak;
      } else if (daysDiff == 1) {
        // Consecutive day! Streak increases
        newStreak = state.currentStreak + 1;
      } else {
        // Gap of 2+ days, restarts streak
        newStreak = 1;
      }
    }

    if (newStreak > newBestStreak) {
      newBestStreak = newStreak;
    }

    // 3. Update Counters
    final newTotalTasks = state.totalTasksCompleted + 1;
    final newUrgentTasks = (task.priority == TaskPriority.urgent ||
            task.priority == TaskPriority.high)
        ? state.totalUrgentCompleted + 1
        : state.totalUrgentCompleted;
    final newSubtasks = state.totalSubtasksCompleted +
        task.subtasks.where((s) => s.isCompleted).length;

    // 4. Badge Evaluation
    final unlockedBadges = List<String>.from(state.unlockedBadgeIds);
    ProductivityBadge? newlyUnlockedBadge;

    void checkBadge(String id, bool condition) {
      if (condition && !unlockedBadges.contains(id)) {
        unlockedBadges.add(id);
        final badge = ProductivityBadge.findById(id);
        if (badge != null) {
          xp += badge.xpReward;
          newlyUnlockedBadge ??= badge;
        }
      }
    }

    // Check all achievement criteria
    checkBadge('first_spark', newTotalTasks >= 1);
    checkBadge('streak_3', newStreak >= 3);
    checkBadge('streak_7', newStreak >= 7);
    checkBadge('streak_14', newStreak >= 14);
    checkBadge('streak_30', newStreak >= 30);
    checkBadge('boss_slayer', newUrgentTasks >= 5);
    checkBadge('early_bird', now.hour < 9);
    checkBadge('night_owl', now.hour >= 22);
    checkBadge('subtask_samurai', newSubtasks >= 10);
    checkBadge('centurion', newTotalTasks >= 100);

    final newTotalXp = state.totalXp + xp;

    final updatedStats = state.copyWith(
      totalXp: newTotalXp,
      currentStreak: newStreak,
      bestStreak: newBestStreak,
      lastCompletionDate: now,
      unlockedBadgeIds: unlockedBadges,
      totalTasksCompleted: newTotalTasks,
      totalUrgentCompleted: newUrgentTasks,
      totalSubtasksCompleted: newSubtasks,
    );

    await _saveStats(updatedStats);

    final event = GamificationRewardEvent(
      xpEarned: xp,
      newTotalXp: newTotalXp,
      newLevel: updatedStats.level,
      leveledUp: updatedStats.level > prevLevel,
      unlockedBadge: newlyUnlockedBadge,
      currentStreak: newStreak,
    );

    return event;
  }

  /// Rolls back XP gracefully if a task is unchecked.
  Future<void> recordTaskUncompletion(Task task) async {
    int xpDeduction = 25;
    if (task.priority == TaskPriority.urgent ||
        task.priority == TaskPriority.high) {
      xpDeduction += 25;
    }
    final newXp = (state.totalXp - xpDeduction).clamp(0, 999999);
    final newTasks = (state.totalTasksCompleted - 1).clamp(0, 999999);

    final updated = state.copyWith(
      totalXp: newXp,
      totalTasksCompleted: newTasks,
    );
    await _saveStats(updated);
  }

  /// Awards focus session XP (1 XP/minute + 25 Pomodoro bonus) and checks focus badges.
  Future<GamificationRewardEvent> recordFocusSession(int minutes) async {
    if (minutes <= 0) {
      return GamificationRewardEvent(
        xpEarned: 0,
        newTotalXp: state.totalXp,
        newLevel: state.level,
        leveledUp: false,
        currentStreak: state.currentStreak,
      );
    }

    final prevLevel = state.level;
    int xp = minutes;
    if (minutes >= 25) {
      xp += 25; // 25-minute Pomodoro completion bounty!
    }

    final newFocusMinutes = state.totalFocusMinutes + minutes;
    final unlockedBadges = List<String>.from(state.unlockedBadgeIds);
    ProductivityBadge? newlyUnlockedBadge;

    if (newFocusMinutes >= 60 && !unlockedBadges.contains('deep_focus')) {
      unlockedBadges.add('deep_focus');
      final badge = ProductivityBadge.findById('deep_focus');
      if (badge != null) {
        xp += badge.xpReward;
        newlyUnlockedBadge = badge;
      }
    }

    final newTotalXp = state.totalXp + xp;

    final updated = state.copyWith(
      totalXp: newTotalXp,
      totalFocusMinutes: newFocusMinutes,
      unlockedBadgeIds: unlockedBadges,
    );
    await _saveStats(updated);

    return GamificationRewardEvent(
      xpEarned: xp,
      newTotalXp: newTotalXp,
      newLevel: updated.level,
      leveledUp: updated.level > prevLevel,
      unlockedBadge: newlyUnlockedBadge,
      currentStreak: state.currentStreak,
    );
  }

  /// Reset gamification stats.
  Future<void> resetStats() async {
    await _saveStats(const GamificationStats());
  }
}

/// Global provider for the Gamification engine.
final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationStats>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return GamificationNotifier(prefs);
});
