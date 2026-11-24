import 'package:flutter/material.dart';

/// Achievement badge definition representing milestones in Taskora.
class ProductivityBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int xpReward;
  final String category;

  const ProductivityBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.category,
  });

  /// Master catalog of all unlockable achievement badges.
  static const List<ProductivityBadge> allBadges = [
    ProductivityBadge(
      id: 'first_spark',
      title: 'First Spark',
      description: 'Completed your very first task in Taskora.',
      icon: Icons.flash_on_rounded,
      xpReward: 50,
      category: 'Milestones',
    ),
    ProductivityBadge(
      id: 'streak_3',
      title: 'On A Roll',
      description: 'Maintained a 3-day daily completion streak.',
      icon: Icons.local_fire_department_rounded,
      xpReward: 100,
      category: 'Streaks',
    ),
    ProductivityBadge(
      id: 'streak_7',
      title: 'Unstoppable Force',
      description: 'Reached a 7-day daily completion streak.',
      icon: Icons.whatshot_rounded,
      xpReward: 250,
      category: 'Streaks',
    ),
    ProductivityBadge(
      id: 'streak_14',
      title: 'Habit Titan',
      description: 'Maintained an unbroken 14-day execution streak.',
      icon: Icons.shield_rounded,
      xpReward: 500,
      category: 'Streaks',
    ),
    ProductivityBadge(
      id: 'streak_30',
      title: 'Iron Will',
      description: 'Conquered 30 consecutive days of productivity.',
      icon: Icons.military_tech_rounded,
      xpReward: 1000,
      category: 'Streaks',
    ),
    ProductivityBadge(
      id: 'boss_slayer',
      title: 'Boss Slayer',
      description: 'Completed 5 high or urgent priority tasks.',
      icon: Icons.bolt_rounded,
      xpReward: 150,
      category: 'Tasks',
    ),
    ProductivityBadge(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Completed a task before 9:00 AM.',
      icon: Icons.wb_sunny_rounded,
      xpReward: 75,
      category: 'Habits',
    ),
    ProductivityBadge(
      id: 'night_owl',
      title: 'Night Owl',
      description: 'Crushed a task after 10:00 PM.',
      icon: Icons.nights_stay_rounded,
      xpReward: 75,
      category: 'Habits',
    ),
    ProductivityBadge(
      id: 'deep_focus',
      title: 'Deep Focus Master',
      description: 'Logged 60+ minutes of focused Pomodoro work.',
      icon: Icons.timer_rounded,
      xpReward: 200,
      category: 'Focus',
    ),
    ProductivityBadge(
      id: 'subtask_samurai',
      title: 'Subtask Samurai',
      description: 'Completed 10 subtasks across your projects.',
      icon: Icons.checklist_rounded,
      xpReward: 100,
      category: 'Tasks',
    ),
    ProductivityBadge(
      id: 'clean_slate',
      title: 'Clean Slate',
      description: 'Completed all scheduled tasks for today.',
      icon: Icons.task_alt_rounded,
      xpReward: 150,
      category: 'Milestones',
    ),
    ProductivityBadge(
      id: 'centurion',
      title: 'Centurion',
      description: 'Conquered 100 total completed tasks in Taskora.',
      icon: Icons.emoji_events_rounded,
      xpReward: 1000,
      category: 'Mastery',
    ),
  ];

  static ProductivityBadge? findById(String id) {
    try {
      return allBadges.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Comprehensive user gamification statistics and streak status.
class GamificationStats {
  final int totalXp;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastCompletionDate;
  final List<String> unlockedBadgeIds;
  final int totalTasksCompleted;
  final int totalUrgentCompleted;
  final int totalSubtasksCompleted;
  final int totalFocusMinutes;

  const GamificationStats({
    this.totalXp = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastCompletionDate,
    this.unlockedBadgeIds = const [],
    this.totalTasksCompleted = 0,
    this.totalUrgentCompleted = 0,
    this.totalSubtasksCompleted = 0,
    this.totalFocusMinutes = 0,
  });

  /// Level curve thresholds
  static const List<int> levelThresholds = [
    0,     // Level 1
    100,   // Level 2
    250,   // Level 3
    450,   // Level 4
    700,   // Level 5
    1050,  // Level 6
    1500,  // Level 7
    2050,  // Level 8
    2700,  // Level 9
    3500,  // Level 10
    4500,  // Level 11
    6000,  // Level 12+
  ];

  /// Computes the current user level (1 to 12+) based on total accumulated XP.
  int get level {
    for (int i = levelThresholds.length - 1; i >= 0; i--) {
      if (totalXp >= levelThresholds[i]) {
        return i + 1;
      }
    }
    return 1;
  }

  /// Title associated with the user's productivity tier.
  String get levelTitle {
    return switch (level) {
      1 => 'Apprentice Initiate',
      2 => 'Focus Explorer',
      3 => 'Task Striker',
      4 => 'Momentum Builder',
      5 => 'Productivity Architect',
      6 => 'Flow State Specialist',
      7 => 'Deep Work Champion',
      8 => 'Strategic Virtuoso',
      9 => 'Zen Mastermind',
      10 => 'Productivity Overlord',
      11 => 'Legendary Luminary',
      _ => 'Transcendental Titan',
    };
  }

  /// XP floor for current level.
  int get currentLevelBaseXp {
    final lvl = level;
    if (lvl <= 1) return 0;
    if (lvl > levelThresholds.length) return levelThresholds.last;
    return levelThresholds[lvl - 1];
  }

  /// XP target for next level.
  int get nextLevelTargetXp {
    final lvl = level;
    if (lvl >= levelThresholds.length) {
      return levelThresholds.last + 1500;
    }
    return levelThresholds[lvl];
  }

  /// Progress fraction (0.0 to 1.0) towards the next level.
  double get levelProgress {
    final base = currentLevelBaseXp;
    final target = nextLevelTargetXp;
    final range = target - base;
    if (range <= 0) return 1.0;
    final earned = (totalXp - base).clamp(0, range);
    return earned / range;
  }

  /// XP needed to reach next rank.
  int get xpToNextLevel {
    return (nextLevelTargetXp - totalXp).clamp(0, 999999);
  }

  /// Checks if at least one task was completed today.
  bool get isStreakActiveToday {
    if (lastCompletionDate == null) return false;
    final now = DateTime.now();
    return lastCompletionDate!.year == now.year &&
        lastCompletionDate!.month == now.month &&
        lastCompletionDate!.day == now.day;
  }

  /// True if user had an active streak yesterday, but hasn't completed any task yet today.
  bool get isStreakAtRisk {
    if (currentStreak == 0 || isStreakActiveToday || lastCompletionDate == null) {
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(
      lastCompletionDate!.year,
      lastCompletionDate!.month,
      lastCompletionDate!.day,
    );
    final diffDays = today.difference(lastDay).inDays;
    return diffDays == 1;
  }

  /// User-friendly streak status phrase.
  String get streakStatusMessage {
    if (currentStreak == 0) {
      return 'Complete a task to ignite your streak! 🔥';
    }
    if (isStreakActiveToday) {
      return 'Streak protected today! Great job! ✨';
    }
    if (isStreakAtRisk) {
      return 'Streak at risk! Complete 1 task today ⏳';
    }
    return 'Ignite your streak today! 🔥';
  }

  GamificationStats copyWith({
    int? totalXp,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastCompletionDate,
    List<String>? unlockedBadgeIds,
    int? totalTasksCompleted,
    int? totalUrgentCompleted,
    int? totalSubtasksCompleted,
    int? totalFocusMinutes,
  }) {
    return GamificationStats(
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastCompletionDate: lastCompletionDate ?? this.lastCompletionDate,
      unlockedBadgeIds: unlockedBadgeIds ?? this.unlockedBadgeIds,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      totalUrgentCompleted: totalUrgentCompleted ?? this.totalUrgentCompleted,
      totalSubtasksCompleted:
          totalSubtasksCompleted ?? this.totalSubtasksCompleted,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalXp': totalXp,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastCompletionDate': lastCompletionDate?.toIso8601String(),
      'unlockedBadgeIds': unlockedBadgeIds,
      'totalTasksCompleted': totalTasksCompleted,
      'totalUrgentCompleted': totalUrgentCompleted,
      'totalSubtasksCompleted': totalSubtasksCompleted,
      'totalFocusMinutes': totalFocusMinutes,
    };
  }

  factory GamificationStats.fromJson(Map<String, dynamic> json) {
    return GamificationStats(
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
      lastCompletionDate: json['lastCompletionDate'] != null
          ? DateTime.tryParse(json['lastCompletionDate'] as String)
          : null,
      unlockedBadgeIds: (json['unlockedBadgeIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      totalTasksCompleted:
          (json['totalTasksCompleted'] as num?)?.toInt() ?? 0,
      totalUrgentCompleted:
          (json['totalUrgentCompleted'] as num?)?.toInt() ?? 0,
      totalSubtasksCompleted:
          (json['totalSubtasksCompleted'] as num?)?.toInt() ?? 0,
      totalFocusMinutes:
          (json['totalFocusMinutes'] as num?)?.toInt() ?? 0,
    );
  }
}
