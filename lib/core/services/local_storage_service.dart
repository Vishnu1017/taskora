import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/tasks/domain/category_model.dart';
import '../../features/tasks/domain/priority_enum.dart';
import '../../features/tasks/domain/recurrence_enum.dart';
import '../../features/tasks/domain/subtask_model.dart';
import '../../features/tasks/domain/task_model.dart';

/// Fast, offline-first local storage service persisting data via atomic JSON.
class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static const String _keyTasks = 'taskora_tasks_storage';
  static const String _keyCategories = 'taskora_categories_storage';
  static const String _keySeeded = 'taskora_seeded_sample_data_v1';

  /// Load persisted tasks from storage or initialize sample dataset.
  Future<List<Task>> loadTasks() async {
    final rawJson = _prefs.getString(_keyTasks);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawJson) as List<dynamic>;
        return decoded
            .map((item) => Task.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    // Seed initial realistic sample data on first launch
    final seeded = _prefs.getBool(_keySeeded) ?? false;
    if (!seeded) {
      final initialTasks = _generateInitialSampleTasks();
      await saveTasks(initialTasks);
      await _prefs.setBool(_keySeeded, true);
      return initialTasks;
    }

    return [];
  }

  /// Reset to fresh default sample tasks.
  Future<List<Task>> resetToSampleTasks() async {
    final initialTasks = _generateInitialSampleTasks();
    await saveTasks(initialTasks);
    await _prefs.setBool(_keySeeded, true);
    return initialTasks;
  }

  /// Remove all completed tasks from storage.
  Future<List<Task>> clearCompletedTasks() async {
    final currentTasks = await loadTasks();
    final remaining = currentTasks.where((t) => !t.isCompleted).toList();
    await saveTasks(remaining);
    return remaining;
  }

  /// Persist tasks list atomically.
  Future<void> saveTasks(List<Task> tasks) async {
    final rawJson = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await _prefs.setString(_keyTasks, rawJson);
  }

  /// Load custom categories or return defaults.
  Future<List<TaskCategory>> loadCategories() async {
    final rawJson = _prefs.getString(_keyCategories);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawJson) as List<dynamic>;
        return decoded
            .map((item) => TaskCategory.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    return TaskCategory.defaultCategories;
  }

  /// Persist custom categories list.
  Future<void> saveCategories(List<TaskCategory> categories) async {
    final rawJson = jsonEncode(categories.map((c) => c.toJson()).toList());
    await _prefs.setString(_keyCategories, rawJson);
  }

  /// Full backup JSON export for data control.
  String exportBackupJson(List<Task> tasks, List<TaskCategory> categories) {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Import backup JSON data into local store.
  ({List<Task> tasks, List<TaskCategory> categories})? importBackupJson(
    String rawJson,
  ) {
    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      final tasksJson = decoded['tasks'] as List<dynamic>? ?? [];
      final categoriesJson = decoded['categories'] as List<dynamic>? ?? [];

      final importedTasks = tasksJson
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList();

      final importedCategories = categoriesJson
          .map((item) => TaskCategory.fromJson(item as Map<String, dynamic>))
          .toList();

      return (tasks: importedTasks, categories: importedCategories);
    } catch (_) {
      return null;
    }
  }

  List<Task> _generateInitialSampleTasks() {
    final now = DateTime.now();

    return [
      Task(
        id: 'sample-task-1',
        title: 'Review System Architecture with Mobile Team',
        description:
            'Conduct deep-dive review into Clean Architecture, Riverpod state models, and offline caching performance.',
        isCompleted: false,
        priority: TaskPriority.urgent,
        categoryId: 'work',
        dueDate: DateTime(now.year, now.month, now.day, 16, 0),
        reminderTime: DateTime(now.year, now.month, now.day, 15, 45),
        recurrence: TaskRecurrence.none,
        tags: const ['Architecture', 'Flutter', 'Core'],
        focusedMinutes: 45,
        subtasks: [
          Subtask(
            id: 'sub-1-1',
            title: 'Verify Riverpod provider invalidation flow',
            isCompleted: true,
            createdAt: now.subtract(const Duration(hours: 3)),
          ),
          Subtask(
            id: 'sub-1-2',
            title: 'Benchmark tablet Master-Detail pane rendering',
            isCompleted: true,
            createdAt: now.subtract(const Duration(hours: 2)),
          ),
          Subtask(
            id: 'sub-1-3',
            title: 'Document state transition lifecycle',
            isCompleted: false,
            createdAt: now.subtract(const Duration(hours: 1)),
          ),
        ],
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Task(
        id: 'sample-task-2',
        title: 'Morning 5km Run & Stretching',
        description:
            'Maintain weekly cardio streak and record pace metrics in health tracker.',
        isCompleted: true,
        priority: TaskPriority.high,
        categoryId: 'health',
        dueDate: DateTime(now.year, now.month, now.day, 7, 30),
        recurrence: TaskRecurrence.none,
        tags: const ['Cardio', 'Fitness'],
        focusedMinutes: 30,
        subtasks: [
          Subtask(
            id: 'sub-2-1',
            title: 'Dynamic warm-up stretching (5 mins)',
            isCompleted: true,
            createdAt: now.subtract(const Duration(hours: 8)),
          ),
          Subtask(
            id: 'sub-2-2',
            title: 'Continuous 5km run',
            isCompleted: true,
            createdAt: now.subtract(const Duration(hours: 7)),
          ),
        ],
        createdAt: now.subtract(const Duration(days: 2)),
        completedAt: now.subtract(const Duration(hours: 6)),
      ),
      Task(
        id: 'sample-task-3',
        title: 'Study Dart 3 Pattern Matching & Sealed Classes',
        description:
            'Master destructuring, algebraic data types, and compiler-checked switch expressions.',
        isCompleted: false,
        priority: TaskPriority.medium,
        categoryId: 'study',
        dueDate: now.add(const Duration(days: 1, hours: 4)),
        reminderTime: now.add(const Duration(days: 1, hours: 3, minutes: 45)),
        recurrence: TaskRecurrence.none,
        tags: const ['Dart3', 'Learning'],
        focusedMinutes: 50,
        subtasks: [
          Subtask(
            id: 'sub-3-1',
            title: 'Read Dart language specification section 4',
            isCompleted: true,
            createdAt: now.subtract(const Duration(hours: 4)),
          ),
          Subtask(
            id: 'sub-3-2',
            title: 'Build miniature CLI sample using records & patterns',
            isCompleted: false,
            createdAt: now.subtract(const Duration(hours: 3)),
          ),
        ],
        createdAt: now.subtract(const Duration(hours: 10)),
      ),
      Task(
        id: 'sample-task-4',
        title: 'Monthly Budget Reconciliation',
        description:
            'Review investment contributions, categorise expenses, and update emergency fund spreadsheet.',
        isCompleted: false,
        priority: TaskPriority.low,
        categoryId: 'finance',
        dueDate: now.add(const Duration(days: 3)),
        recurrence: TaskRecurrence.none,
        tags: const ['Finance', 'Budget'],
        focusedMinutes: 0,
        subtasks: const [],
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }
}
