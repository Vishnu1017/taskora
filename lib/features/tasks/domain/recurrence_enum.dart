import 'package:flutter/material.dart';

/// Recurrence schedule for automated task repetition.
enum TaskRecurrence {
  none,
  daily,
  weekdays,
  weekly,
  monthly;

  String get displayName => switch (this) {
    TaskRecurrence.none => 'Does not repeat',
    TaskRecurrence.daily => 'Daily',
    TaskRecurrence.weekdays => 'Every Weekday (Mon-Fri)',
    TaskRecurrence.weekly => 'Weekly',
    TaskRecurrence.monthly => 'Monthly',
  };

  IconData get icon => switch (this) {
    TaskRecurrence.none => Icons.event_busy_rounded,
    TaskRecurrence.daily => Icons.repeat_rounded,
    TaskRecurrence.weekdays => Icons.business_center_rounded,
    TaskRecurrence.weekly => Icons.calendar_view_week_rounded,
    TaskRecurrence.monthly => Icons.calendar_month_rounded,
  };

  /// Calculates next due date based on schedule.
  DateTime? calculateNextDueDate(DateTime current) {
    switch (this) {
      case TaskRecurrence.none:
        return null;
      case TaskRecurrence.daily:
        return current.add(const Duration(days: 1));
      case TaskRecurrence.weekdays:
        var next = current.add(const Duration(days: 1));
        while (next.weekday == DateTime.saturday || next.weekday == DateTime.sunday) {
          next = next.add(const Duration(days: 1));
        }
        return next;
      case TaskRecurrence.weekly:
        return current.add(const Duration(days: 7));
      case TaskRecurrence.monthly:
        return DateTime(current.year, current.month + 1, current.day, current.hour, current.minute);
    }
  }

  static TaskRecurrence fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'daily':
        return TaskRecurrence.daily;
      case 'weekdays':
        return TaskRecurrence.weekdays;
      case 'weekly':
        return TaskRecurrence.weekly;
      case 'monthly':
        return TaskRecurrence.monthly;
      case 'none':
      default:
        return TaskRecurrence.none;
    }
  }
}
