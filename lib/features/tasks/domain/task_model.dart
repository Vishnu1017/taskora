import 'priority_enum.dart';
import 'recurrence_enum.dart';
import 'subtask_model.dart';

/// Primary Task Model for Taskora.
/// Encompasses full task metadata: checklist, recurrence, priority, reminders, and focus time.
class Task {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final TaskPriority priority;
  final String categoryId;
  final DateTime? dueDate;
  final DateTime? reminderTime;
  final TaskRecurrence recurrence;
  final List<Subtask> subtasks;
  final List<String> tags;
  final int focusedMinutes;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.categoryId = 'work',
    this.dueDate,
    this.reminderTime,
    this.recurrence = TaskRecurrence.none,
    this.subtasks = const [],
    this.tags = const [],
    this.focusedMinutes = 0,
    required this.createdAt,
    this.completedAt,
  });

  int get subtasksTotal => subtasks.length;
  int get subtasksCompleted => subtasks.where((s) => s.isCompleted).length;

  double get progressRatio {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    return subtasksCompleted / subtasksTotal;
  }

  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isDueUpcoming {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dueDate!.isAfter(today);
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    String? categoryId,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? reminderTime,
    bool clearReminderTime = false,
    TaskRecurrence? recurrence,
    List<Subtask>? subtasks,
    List<String>? tags,
    int? focusedMinutes,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    isCompleted: isCompleted ?? this.isCompleted,
    priority: priority ?? this.priority,
    categoryId: categoryId ?? this.categoryId,
    dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    reminderTime: clearReminderTime ? null : (reminderTime ?? this.reminderTime),
    recurrence: recurrence ?? this.recurrence,
    subtasks: subtasks ?? this.subtasks,
    tags: tags ?? this.tags,
    focusedMinutes: focusedMinutes ?? this.focusedMinutes,
    createdAt: createdAt ?? this.createdAt,
    completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'priority': priority.name,
    'categoryId': categoryId,
    'dueDate': dueDate?.toIso8601String(),
    'reminderTime': reminderTime?.toIso8601String(),
    'recurrence': recurrence.name,
    'subtasks': subtasks.map((s) => s.toJson()).toList(),
    'tags': tags,
    'focusedMinutes': focusedMinutes,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    isCompleted: json['isCompleted'] as bool? ?? false,
    priority: TaskPriority.fromString(json['priority'] as String?),
    categoryId: json['categoryId'] as String? ?? 'work',
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
    reminderTime: json['reminderTime'] != null
        ? DateTime.parse(json['reminderTime'] as String)
        : null,
    recurrence: TaskRecurrence.fromString(json['recurrence'] as String?),
    subtasks: (json['subtasks'] as List<dynamic>?)
            ?.map((s) => Subtask.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [],
    tags: (json['tags'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [],
    focusedMinutes: json['focusedMinutes'] as int? ?? 0,
    createdAt: DateTime.parse(json['createdAt'] as String),
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'] as String)
        : null,
  );
}
