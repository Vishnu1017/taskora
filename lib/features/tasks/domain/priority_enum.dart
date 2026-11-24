import 'package:flutter/material.dart';
import 'package:taskora/core/theme/app_colors.dart';

/// Semantic priority levels for Taskora tasks.
enum TaskPriority {
  urgent,
  high,
  medium,
  low;

  String get displayName => switch (this) {
    TaskPriority.urgent => 'Urgent',
    TaskPriority.high => 'High',
    TaskPriority.medium => 'Medium',
    TaskPriority.low => 'Low',
  };

  int get sortWeight => switch (this) {
    TaskPriority.urgent => 4,
    TaskPriority.high => 3,
    TaskPriority.medium => 2,
    TaskPriority.low => 1,
  };

  Color get color => switch (this) {
    TaskPriority.urgent => AppColors.priorityUrgent,
    TaskPriority.high => AppColors.priorityHigh,
    TaskPriority.medium => AppColors.priorityMedium,
    TaskPriority.low => AppColors.priorityLow,
  };

  Color get containerColor => switch (this) {
    TaskPriority.urgent => AppColors.priorityUrgentContainer,
    TaskPriority.high => AppColors.priorityHighContainer,
    TaskPriority.medium => AppColors.priorityMediumContainer,
    TaskPriority.low => AppColors.priorityLowContainer,
  };

  IconData get icon => switch (this) {
    TaskPriority.urgent => Icons.error_rounded,
    TaskPriority.high => Icons.priority_high_rounded,
    TaskPriority.medium => Icons.remove_rounded,
    TaskPriority.low => Icons.arrow_downward_rounded,
  };

  static TaskPriority fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'urgent':
        return TaskPriority.urgent;
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      case 'medium':
      default:
        return TaskPriority.medium;
    }
  }
}
