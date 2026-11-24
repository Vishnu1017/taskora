import 'package:flutter/material.dart';
import 'category_model.dart';
import 'priority_enum.dart';
import 'recurrence_enum.dart';

/// Structured result of natural language task parsing.
class ParsedTaskResult {
  final String rawInput;
  final String cleanTitle;
  final DateTime? dueDate;
  final TimeOfDay? dueTime;
  final TaskPriority? priority;
  final TaskCategory? category;
  final TaskRecurrence? recurrence;
  final int? estimatedMinutes;
  final List<String> detectedTags;
  final List<NlpDetectedToken> tokens;

  const ParsedTaskResult({
    required this.rawInput,
    required this.cleanTitle,
    this.dueDate,
    this.dueTime,
    this.priority,
    this.category,
    this.recurrence,
    this.estimatedMinutes,
    this.detectedTags = const [],
    this.tokens = const [],
  });

  bool get hasAnyAttributes =>
      dueDate != null ||
      priority != null ||
      category != null ||
      recurrence != null ||
      estimatedMinutes != null ||
      detectedTags.isNotEmpty;

  /// Combined DateTime using [dueDate] and [dueTime] if present.
  DateTime? get combinedDueDateTime {
    if (dueDate == null) return null;
    final time = dueTime ?? const TimeOfDay(hour: 17, minute: 0);
    return DateTime(
      dueDate!.year,
      dueDate!.month,
      dueDate!.day,
      time.hour,
      time.minute,
    );
  }
}

/// Token descriptor representing an attribute extracted by the NLP parser.
class NlpDetectedToken {
  final String text;
  final NlpTokenType type;
  final String displayLabel;
  final IconData icon;

  const NlpDetectedToken({
    required this.text,
    required this.type,
    required this.displayLabel,
    required this.icon,
  });
}

enum NlpTokenType {
  date,
  time,
  priority,
  category,
  recurrence,
  duration,
  tag,
}

/// Intelligent, offline Natural Language Processor for Taskora tasks.
/// Parses dates, times, priorities (!urgent, !high), categories (#work),
/// durations (~30m), and recurrences from conversational user input.
class NlpTaskParser {
  NlpTaskParser._();

  /// Parses the input string and resolves against the available categories.
  static ParsedTaskResult parse(
    String input, {
    List<TaskCategory> availableCategories = TaskCategory.defaultCategories,
    DateTime? referenceDate,
  }) {
    if (input.trim().isEmpty) {
      return ParsedTaskResult(rawInput: input, cleanTitle: '');
    }

    final now = referenceDate ?? DateTime.now();
    var workingText = input;
    final detectedTokens = <NlpDetectedToken>[];

    // 1. Parse Priority: !urgent, !high, !medium, !low, !p1, !p2, !p3, !p4
    TaskPriority? priority;
    final priorityRegex = RegExp(
      r'(?:^|\s)!(urgent|high|medium|low|p1|p2|p3|p4)(?=\s|$)',
      caseSensitive: false,
    );
    final priorityMatch = priorityRegex.firstMatch(workingText);
    if (priorityMatch != null) {
      final tokenStr = priorityMatch.group(0)!.trim();
      final tag = priorityMatch.group(1)!.toLowerCase();
      priority = switch (tag) {
        'urgent' || 'p1' => TaskPriority.urgent,
        'high' || 'p2' => TaskPriority.high,
        'medium' || 'p3' => TaskPriority.medium,
        'low' || 'p4' => TaskPriority.low,
        _ => null,
      };

      if (priority != null) {
        detectedTokens.add(
          NlpDetectedToken(
            text: tokenStr,
            type: NlpTokenType.priority,
            displayLabel: priority.displayName,
            icon: priority.icon,
          ),
        );
        workingText = workingText.replaceFirst(priorityMatch.group(0)!, ' ');
      }
    }

    // 2. Parse Category: #work, #personal, #health, #study, #finance, or any available category
    TaskCategory? category;
    final categoryRegex = RegExp(r'(?:^|\s)#([a-zA-Z0-9_\-]+)(?=\s|$)');
    final categoryMatch = categoryRegex.firstMatch(workingText);
    if (categoryMatch != null) {
      final tokenStr = categoryMatch.group(0)!.trim();
      final name = categoryMatch.group(1)!.toLowerCase();

      // Find matching category
      for (final cat in availableCategories) {
        if (cat.name.toLowerCase() == name || cat.id.toLowerCase() == name) {
          category = cat;
          break;
        }
      }

      if (category != null) {
        detectedTokens.add(
          NlpDetectedToken(
            text: tokenStr,
            type: NlpTokenType.category,
            displayLabel: category.name,
            icon: category.icon,
          ),
        );
        workingText = workingText.replaceFirst(categoryMatch.group(0)!, ' ');
      }
    }

    // 3. Parse Duration: ~30m, ~45mins, ~1h, ~2hours, ~90m
    int? estimatedMinutes;
    final durationRegex = RegExp(
      r'(?:^|\s)~([0-9]+(?:\.[0-9]+)?)\s*(m|min|mins|minutes|h|hr|hrs|hours)(?=\s|$)',
      caseSensitive: false,
    );
    final durationMatch = durationRegex.firstMatch(workingText);
    if (durationMatch != null) {
      final tokenStr = durationMatch.group(0)!.trim();
      final numStr = durationMatch.group(1)!;
      final unit = durationMatch.group(2)!.toLowerCase();
      final value = double.tryParse(numStr) ?? 0;

      if (unit.startsWith('h')) {
        estimatedMinutes = (value * 60).round();
      } else {
        estimatedMinutes = value.round();
      }

      if (estimatedMinutes > 0) {
        detectedTokens.add(
          NlpDetectedToken(
            text: tokenStr,
            type: NlpTokenType.duration,
            displayLabel: '${estimatedMinutes}m focus',
            icon: Icons.timer_outlined,
          ),
        );
        workingText = workingText.replaceFirst(durationMatch.group(0)!, ' ');
      }
    }

    // 4. Parse Recurrence: daily, every day, weekdays, every week, weekly, monthly
    TaskRecurrence? recurrence;
    final recurrenceRegex = RegExp(
      r'\b(every\s+(?:day|weekday|week|month)|daily|weekdays|weekly|monthly)\b',
      caseSensitive: false,
    );
    final recurrenceMatch = recurrenceRegex.firstMatch(workingText);
    if (recurrenceMatch != null) {
      final tokenStr = recurrenceMatch.group(0)!;
      final lower = tokenStr.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

      if (lower == 'daily' || lower == 'every day') {
        recurrence = TaskRecurrence.daily;
      } else if (lower == 'weekdays' || lower == 'every weekday') {
        recurrence = TaskRecurrence.weekdays;
      } else if (lower == 'weekly' || lower == 'every week') {
        recurrence = TaskRecurrence.weekly;
      } else if (lower == 'monthly' || lower == 'every month') {
        recurrence = TaskRecurrence.monthly;
      }

      if (recurrence != null) {
        detectedTokens.add(
          NlpDetectedToken(
            text: tokenStr,
            type: NlpTokenType.recurrence,
            displayLabel: recurrence.displayName,
            icon: recurrence.icon,
          ),
        );
        workingText = workingText.replaceFirst(recurrenceMatch.group(0)!, ' ');
      }
    }

    // 5. Parse Time: "at 4pm", "at 4:30 pm", "16:00", "5pm", "10:15am", "noon", "midnight"
    TimeOfDay? dueTime;
    final timeRegex = RegExp(
      r'(?:\bat\s+)?(\b(?:noon|midnight)\b|\b\d{1,2}(?::\d{2})?\s*(?:am|pm)\b|\b\d{1,2}:\d{2}\b)',
      caseSensitive: false,
    );
    final timeMatch = timeRegex.firstMatch(workingText);
    if (timeMatch != null) {
      final tokenStr = timeMatch.group(0)!;
      final rawTime = timeMatch.group(1)!.trim().toLowerCase();

      dueTime = _parseTimeOfDay(rawTime);
      if (dueTime != null) {
        final hour = dueTime.hour;
        final minute = dueTime.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

        detectedTokens.add(
          NlpDetectedToken(
            text: tokenStr,
            type: NlpTokenType.time,
            displayLabel: '$displayHour:$minute $period',
            icon: Icons.access_time_rounded,
          ),
        );
        workingText = workingText.replaceFirst(timeMatch.group(0)!, ' ');
      }
    }

    // 6. Parse Date:
    // Relative keywords: today, tonight, tomorrow, tmrw, yesterday
    // Days offset: in 2 days, in 3 weeks
    // Weekdays: monday, next friday, this sunday
    // Explicit dates: nov 25, 25 nov, 12/25
    DateTime? dueDate;

    // A. Relative keywords
    final relativeDateRegex = RegExp(
      r'\b(today|tonight|tomorrow|tmrw)\b',
      caseSensitive: false,
    );
    final relDateMatch = relativeDateRegex.firstMatch(workingText);
    if (relDateMatch != null) {
      final tokenStr = relDateMatch.group(0)!;
      final keyword = tokenStr.toLowerCase();

      if (keyword == 'today') {
        dueDate = DateTime(now.year, now.month, now.day);
      } else if (keyword == 'tonight') {
        dueDate = DateTime(now.year, now.month, now.day);
        dueTime ??= const TimeOfDay(hour: 20, minute: 0);
      } else if (keyword == 'tomorrow' || keyword == 'tmrw') {
        dueDate = DateTime(now.year, now.month, now.day + 1);
      }

      if (dueDate != null) {
        detectedTokens.add(
          NlpDetectedToken(
            text: tokenStr,
            type: NlpTokenType.date,
            displayLabel: keyword == 'tomorrow' || keyword == 'tmrw' ? 'Tomorrow' : 'Today',
            icon: Icons.calendar_today_rounded,
          ),
        );
        workingText = workingText.replaceFirst(relDateMatch.group(0)!, ' ');
      }
    }

    // B. Offset "in X days" or "in X weeks"
    if (dueDate == null) {
      final offsetRegex = RegExp(
        r'\bin\s+(\d+)\s+(days?|weeks?|months?)\b',
        caseSensitive: false,
      );
      final offsetMatch = offsetRegex.firstMatch(workingText);
      if (offsetMatch != null) {
        final tokenStr = offsetMatch.group(0)!;
        final count = int.tryParse(offsetMatch.group(1)!) ?? 1;
        final unit = offsetMatch.group(2)!.toLowerCase();

        if (unit.startsWith('day')) {
          dueDate = DateTime(now.year, now.month, now.day + count);
        } else if (unit.startsWith('week')) {
          dueDate = DateTime(now.year, now.month, now.day + (count * 7));
        } else if (unit.startsWith('month')) {
          dueDate = DateTime(now.year, now.month + count, now.day);
        }

        if (dueDate != null) {
          detectedTokens.add(
            NlpDetectedToken(
              text: tokenStr,
              type: NlpTokenType.date,
              displayLabel: 'In $count ${offsetMatch.group(2)}',
              icon: Icons.event_rounded,
            ),
          );
          workingText = workingText.replaceFirst(offsetMatch.group(0)!, ' ');
        }
      }
    }

    // C. Weekdays: (on |this |next )?(monday|tuesday|wednesday|thursday|friday|saturday|sunday|mon|tue|wed|thu|fri|sat|sun)
    if (dueDate == null) {
      final weekdayRegex = RegExp(
        r'(?:\b(?:on|this|next)\s+)?\b(monday|tuesday|wednesday|thursday|friday|saturday|sunday|mon|tue|wed|thu|fri|sat|sun)\b',
        caseSensitive: false,
      );
      final weekdayMatch = weekdayRegex.firstMatch(workingText);
      if (weekdayMatch != null) {
        final tokenStr = weekdayMatch.group(0)!;
        final rawDay = weekdayMatch.group(1)!.toLowerCase();
        final isNext = tokenStr.toLowerCase().contains('next');

        final targetWeekday = _weekdayFromStr(rawDay);
        if (targetWeekday != null) {
          dueDate = _nextWeekdayDate(now, targetWeekday, isNext: isNext);
          detectedTokens.add(
            NlpDetectedToken(
              text: tokenStr,
              type: NlpTokenType.date,
              displayLabel: _weekdayName(targetWeekday),
              icon: Icons.date_range_rounded,
            ),
          );
          workingText = workingText.replaceFirst(weekdayMatch.group(0)!, ' ');
        }
      }
    }

    // D. Explicit Month Day: "Nov 25", "25 Nov", "December 15"
    if (dueDate == null) {
      final monthDayRegex = RegExp(
        r'\b(?:on\s+)?(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s+(\d{1,2})(?:st|nd|rd|th)?\b',
        caseSensitive: false,
      );
      final monthDayMatch = monthDayRegex.firstMatch(workingText);
      if (monthDayMatch != null) {
        final tokenStr = monthDayMatch.group(0)!;
        final monthStr = monthDayMatch.group(1)!.toLowerCase();
        final day = int.tryParse(monthDayMatch.group(2)!) ?? 1;
        final month = _monthFromStr(monthStr);

        if (month != null) {
          var year = now.year;
          // If the date is already passed this year, assume next year
          if (DateTime(year, month, day).isBefore(DateTime(now.year, now.month, now.day))) {
            year++;
          }
          dueDate = DateTime(year, month, day);
          detectedTokens.add(
            NlpDetectedToken(
              text: tokenStr,
              type: NlpTokenType.date,
              displayLabel: '$monthStr $day',
              icon: Icons.calendar_month_rounded,
            ),
          );
          workingText = workingText.replaceFirst(monthDayMatch.group(0)!, ' ');
        }
      }
    }

    // Clean up residual title: remove extra whitespace and orphan punctuation
    var cleanTitle = workingText
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Remove leading/trailing prepositions or punctuation like "at ", "on " left over
    cleanTitle = cleanTitle.replaceAll(RegExp(r'^(?:at|on|for|by)\s+', caseSensitive: false), '');
    cleanTitle = cleanTitle.replaceAll(RegExp(r'\s+(?:at|on|for|by)$', caseSensitive: false), '');
    cleanTitle = cleanTitle.trim();

    if (cleanTitle.isEmpty) {
      cleanTitle = input.trim();
    }

    return ParsedTaskResult(
      rawInput: input,
      cleanTitle: cleanTitle,
      dueDate: dueDate,
      dueTime: dueTime,
      priority: priority,
      category: category,
      recurrence: recurrence,
      estimatedMinutes: estimatedMinutes,
      tokens: detectedTokens,
    );
  }

  static TimeOfDay? _parseTimeOfDay(String raw) {
    if (raw == 'noon') return const TimeOfDay(hour: 12, minute: 0);
    if (raw == 'midnight') return const TimeOfDay(hour: 0, minute: 0);

    final match = RegExp(r'^(\d{1,2})(?::(\d{2}))?\s*(am|pm)?$', caseSensitive: false).firstMatch(raw);
    if (match == null) return null;

    var hour = int.tryParse(match.group(1)!) ?? 0;
    final minute = match.group(2) != null ? (int.tryParse(match.group(2)!) ?? 0) : 0;
    final meridiem = match.group(3)?.toLowerCase();

    if (meridiem == 'pm' && hour < 12) hour += 12;
    if (meridiem == 'am' && hour == 12) hour = 0;

    if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null;
  }

  static int? _weekdayFromStr(String str) {
    if (str.startsWith('mon')) return DateTime.monday;
    if (str.startsWith('tue')) return DateTime.tuesday;
    if (str.startsWith('wed')) return DateTime.wednesday;
    if (str.startsWith('thu')) return DateTime.thursday;
    if (str.startsWith('fri')) return DateTime.friday;
    if (str.startsWith('sat')) return DateTime.saturday;
    if (str.startsWith('sun')) return DateTime.sunday;
    return null;
  }

  static String _weekdayName(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Monday',
      DateTime.tuesday => 'Tuesday',
      DateTime.wednesday => 'Wednesday',
      DateTime.thursday => 'Thursday',
      DateTime.friday => 'Friday',
      DateTime.saturday => 'Saturday',
      DateTime.sunday => 'Sunday',
      _ => 'Upcoming',
    };
  }

  static DateTime _nextWeekdayDate(DateTime now, int targetWeekday, {bool isNext = false}) {
    var daysAhead = targetWeekday - now.weekday;
    if (daysAhead <= 0) {
      daysAhead += 7;
    }
    if (isNext) {
      daysAhead += 7;
    }
    return DateTime(now.year, now.month, now.day + daysAhead);
  }

  static int? _monthFromStr(String str) {
    return switch (str.toLowerCase()) {
      'jan' => 1,
      'feb' => 2,
      'mar' => 3,
      'apr' => 4,
      'may' => 5,
      'jun' => 6,
      'jul' => 7,
      'aug' => 8,
      'sep' => 9,
      'oct' => 10,
      'nov' => 11,
      'dec' => 12,
      _ => null,
    };
  }
}
