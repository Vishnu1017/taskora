import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/haptic_feedback_util.dart';
import '../../../gamification/presentation/providers/gamification_provider.dart';
import '../../data/task_repository.dart';
import '../../domain/category_model.dart';
import '../../domain/priority_enum.dart';
import '../../domain/subtask_model.dart';
import '../../domain/task_model.dart';

/// Local storage provider
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

/// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

/// Task repository provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  final notifications = ref.watch(notificationServiceProvider);
  return TaskRepository(storage: storage, notifications: notifications);
});

/// Filter types for dashboard and smart views
enum TaskFilter {
  all,
  today,
  upcoming,
  highPriority,
  overdue,
  completed;

  String get displayName => switch (this) {
    TaskFilter.all => 'All Tasks',
    TaskFilter.today => 'Today',
    TaskFilter.upcoming => 'Upcoming',
    TaskFilter.highPriority => 'High Priority',
    TaskFilter.overdue => 'Overdue',
    TaskFilter.completed => 'Completed',
  };

  IconData get icon => switch (this) {
    TaskFilter.all => Icons.grid_view_rounded,
    TaskFilter.today => Icons.today_rounded,
    TaskFilter.upcoming => Icons.upcoming_rounded,
    TaskFilter.highPriority => Icons.bolt_rounded,
    TaskFilter.overdue => Icons.warning_amber_rounded,
    TaskFilter.completed => Icons.check_circle_outline_rounded,
  };
}

/// Sorting options for tasks list
enum TaskSortBy {
  dueDate,
  priority,
  createdAt,
  title;

  String get displayName => switch (this) {
    TaskSortBy.dueDate => 'Due Date',
    TaskSortBy.priority => 'Priority',
    TaskSortBy.createdAt => 'Date Created',
    TaskSortBy.title => 'Alphabetical',
  };
}

/// Master tasks list StateNotifier
class TaskListNotifier extends StateNotifier<List<Task>> {
  final TaskRepository _repository;
  final Ref? _ref;

  TaskListNotifier(this._repository, [this._ref]) : super([]) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final tasks = await _repository.getTasks();
    state = tasks;
  }

  Future<void> addTask(Task task) async {
    final updated = [task, ...state];
    state = updated;
    await _repository.saveTasks(updated);
    if (task.reminderTime != null) {
      await _repository.scheduleNotification(task);
    }
  }

  Future<void> updateTask(Task task) async {
    final updated = state.map((t) => t.id == task.id ? task : t).toList();
    state = updated;
    await _repository.saveTasks(updated);
    if (task.reminderTime != null) {
      await _repository.scheduleNotification(task);
    } else {
      await _repository.cancelNotification(task.id);
    }
  }

  Future<void> deleteTask(String id) async {
    final updated = state.where((t) => t.id != id).toList();
    state = updated;
    await _repository.saveTasks(updated);
    await _repository.cancelNotification(id);
    await HapticFeedbackUtil.light();
  }

  Future<void> toggleTaskCompletion(String id) async {
    final index = state.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final currentTask = state[index];
    final willBeCompleted = !currentTask.isCompleted;

    Task updatedTask;
    if (willBeCompleted) {
      await HapticFeedbackUtil.taskCompleted();
      await _repository.cancelNotification(id);

      updatedTask = currentTask.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      // Award Gamification XP and update Daily Streak
      if (_ref != null) {
        final reward = await _ref
            .read(gamificationProvider.notifier)
            .recordTaskCompletion(updatedTask);
        _ref.read(latestGamificationRewardProvider.notifier).state = reward;
      }
    } else {
      await HapticFeedbackUtil.selection();
      updatedTask = currentTask.copyWith(
        isCompleted: false,
        clearCompletedAt: true,
      );
      if (updatedTask.reminderTime != null) {
        await _repository.scheduleNotification(updatedTask);
      }

      // Roll back XP gracefully
      if (_ref != null) {
        await _ref
            .read(gamificationProvider.notifier)
            .recordTaskUncompletion(currentTask);
      }
    }

    final updated = state.map((t) => t.id == id ? updatedTask : t).toList();
    state = updated;
    await _repository.saveTasks(updated);
  }

  Future<void> toggleSubtaskCompletion(String taskId, String subtaskId) async {
    final taskIndex = state.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = state[taskIndex];
    final updatedSubtasks = task.subtasks.map((s) {
      if (s.id == subtaskId) {
        return s.copyWith(isCompleted: !s.isCompleted);
      }
      return s;
    }).toList();

    final allSubtasksCompleted = updatedSubtasks.isNotEmpty &&
        updatedSubtasks.every((s) => s.isCompleted);

    final updatedTask = task.copyWith(
      subtasks: updatedSubtasks,
      isCompleted: allSubtasksCompleted ? true : task.isCompleted,
      completedAt: allSubtasksCompleted ? DateTime.now() : task.completedAt,
    );

    await HapticFeedbackUtil.light();
    final updated = state.map((t) => t.id == taskId ? updatedTask : t).toList();
    state = updated;
    await _repository.saveTasks(updated);
  }

  Future<void> addSubtask(String taskId, String title) async {
    if (title.trim().isEmpty) return;

    final taskIndex = state.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = state[taskIndex];
    final newSubtask = Subtask(
      id: const Uuid().v4(),
      title: title.trim(),
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    final updatedTask = task.copyWith(
      subtasks: [...task.subtasks, newSubtask],
      isCompleted: false, // Adding uncompleted subtask resets task completion
      clearCompletedAt: true,
    );

    final updated = state.map((t) => t.id == taskId ? updatedTask : t).toList();
    state = updated;
    await _repository.saveTasks(updated);
  }

  Future<void> deleteSubtask(String taskId, String subtaskId) async {
    final taskIndex = state.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = state[taskIndex];
    final updatedSubtasks =
        task.subtasks.where((s) => s.id != subtaskId).toList();

    final updatedTask = task.copyWith(subtasks: updatedSubtasks);
    final updated = state.map((t) => t.id == taskId ? updatedTask : t).toList();
    state = updated;
    await _repository.saveTasks(updated);
  }

  Future<void> addFocusedMinutes(String taskId, int minutes) async {
    final taskIndex = state.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = state[taskIndex];
    final updatedTask = task.copyWith(
      focusedMinutes: task.focusedMinutes + minutes,
    );

    final updated = state.map((t) => t.id == taskId ? updatedTask : t).toList();
    state = updated;
    await _repository.saveTasks(updated);
  }

  Future<void> reloadFromImport(List<Task> tasks) async {
    state = tasks;
    await _repository.saveTasks(tasks);
  }

  Future<void> clearCompletedTasks() async {
    final remaining = state.where((t) => !t.isCompleted).toList();
    state = remaining;
    await _repository.saveTasks(remaining);
    await HapticFeedbackUtil.light();
  }

  Future<void> resetToSampleTasks() async {
    final freshTasks = await _repository.resetToSampleTasks();
    state = freshTasks;
    await HapticFeedbackUtil.light();
  }
}

final taskListProvider =
    StateNotifierProvider<TaskListNotifier, List<Task>>((ref) {
      final repository = ref.watch(taskRepositoryProvider);
      return TaskListNotifier(repository, ref);
    });

/// Categories StateNotifier
class CategoryListNotifier extends StateNotifier<List<TaskCategory>> {
  final TaskRepository _repository;

  CategoryListNotifier(this._repository) : super(TaskCategory.defaultCategories) {
    _loadInitialCategories();
  }

  Future<void> _loadInitialCategories() async {
    final categories = await _repository.getCategories();
    state = categories;
  }

  Future<void> addCategory(TaskCategory category) async {
    final updated = [...state, category];
    state = updated;
    await _repository.saveCategories(updated);
  }

  Future<void> reloadFromImport(List<TaskCategory> categories) async {
    state = categories;
    await _repository.saveCategories(categories);
  }
}

final categoryListProvider =
    StateNotifierProvider<CategoryListNotifier, List<TaskCategory>>((ref) {
      final repository = ref.watch(taskRepositoryProvider);
      return CategoryListNotifier(repository);
    });

/// Active UI Filters
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);
final selectedTimelineDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final sortByProvider = StateProvider<TaskSortBy>((ref) => TaskSortBy.dueDate);

/// Currently selected task for Master-Detail view on tablets/foldables
final selectedTaskForDetailProvider = StateProvider<Task?>((ref) => null);

/// Filtered, searched, and sorted tasks provider
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskListProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(selectedFilterProvider);
  final categoryFilter = ref.watch(selectedCategoryFilterProvider);
  final sortBy = ref.watch(sortByProvider);

  var list = tasks.where((task) {
    // 1. Text Search query
    if (query.isNotEmpty) {
      final inTitle = task.title.toLowerCase().contains(query);
      final inDesc = task.description.toLowerCase().contains(query);
      final inTags = task.tags.any((t) => t.toLowerCase().contains(query));
      if (!inTitle && !inDesc && !inTags) return false;
    }

    // 2. Category Filter
    if (categoryFilter != null && task.categoryId != categoryFilter) {
      return false;
    }

    // 3. Quick Status Filter
    switch (filter) {
      case TaskFilter.all:
        return true;
      case TaskFilter.today:
        return task.isDueToday && !task.isCompleted;
      case TaskFilter.upcoming:
        return task.isDueUpcoming && !task.isCompleted;
      case TaskFilter.highPriority:
        return (task.priority == TaskPriority.high ||
                task.priority == TaskPriority.urgent) &&
            !task.isCompleted;
      case TaskFilter.overdue:
        return task.isOverdue;
      case TaskFilter.completed:
        return task.isCompleted;
    }
  }).toList();

  // Sort
  list.sort((a, b) {
    switch (sortBy) {
      case TaskSortBy.dueDate:
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      case TaskSortBy.priority:
        return b.priority.sortWeight.compareTo(a.priority.sortWeight);
      case TaskSortBy.createdAt:
        return b.createdAt.compareTo(a.createdAt);
      case TaskSortBy.title:
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    }
  });

  return list;
});

/// Productivity Stats computation
class ProductivityStats {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final double completionRate;
  final int todayCompletedCount;
  final int totalFocusedMinutes;
  final int streakDays;
  final Map<int, int> weekdayCompletions; // Weekday (1=Mon..7=Sun) -> count
  final Map<String, int> categoryDistribution; // categoryId -> count

  const ProductivityStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.completionRate,
    required this.todayCompletedCount,
    required this.totalFocusedMinutes,
    required this.streakDays,
    required this.weekdayCompletions,
    required this.categoryDistribution,
  });
}

final productivityStatsProvider = Provider<ProductivityStats>((ref) {
  final tasks = ref.watch(taskListProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final total = tasks.length;
  final completed = tasks.where((t) => t.isCompleted).length;
  final pending = total - completed;
  final rate = total > 0 ? completed / total : 0.0;

  final todayCompleted = tasks.where((t) {
    if (!t.isCompleted || t.completedAt == null) return false;
    final cDate = t.completedAt!;
    return cDate.year == today.year &&
        cDate.month == today.month &&
        cDate.day == today.day;
  }).length;

  final totalFocus = tasks.fold<int>(0, (sum, t) => sum + t.focusedMinutes);

  // 7-day weekday completions
  final weekdayMap = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
  for (final t in tasks) {
    if (t.isCompleted && t.completedAt != null) {
      final diff = today.difference(t.completedAt!).inDays;
      if (diff >= 0 && diff < 7) {
        final wd = t.completedAt!.weekday;
        weekdayMap[wd] = (weekdayMap[wd] ?? 0) + 1;
      }
    }
  }

  // Category distribution
  final categoryMap = <String, int>{};
  for (final t in tasks) {
    categoryMap[t.categoryId] = (categoryMap[t.categoryId] ?? 0) + 1;
  }

  // Calculate completion streak
  var streak = 0;
  var checkDate = today;
  while (true) {
    final hasCompletedOnDay = tasks.any((t) {
      if (!t.isCompleted || t.completedAt == null) return false;
      final c = t.completedAt!;
      return c.year == checkDate.year &&
          c.month == checkDate.month &&
          c.day == checkDate.day;
    });

    if (hasCompletedOnDay) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
      if (streak > 365) break; // sanity limit
    } else {
      // If today has no completions yet, check yesterday before breaking
      if (checkDate == today && streak == 0) {
        checkDate = checkDate.subtract(const Duration(days: 1));
        final yesterdayCompleted = tasks.any((t) {
          if (!t.isCompleted || t.completedAt == null) return false;
          final c = t.completedAt!;
          return c.year == checkDate.year &&
              c.month == checkDate.month &&
              c.day == checkDate.day;
        });
        if (yesterdayCompleted) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue;
        }
      }
      break;
    }
  }

  return ProductivityStats(
    totalTasks: total,
    completedTasks: completed,
    pendingTasks: pending,
    completionRate: rate,
    todayCompletedCount: todayCompleted,
    totalFocusedMinutes: totalFocus,
    streakDays: streak == 0 && todayCompleted > 0 ? 1 : streak,
    weekdayCompletions: weekdayMap,
    categoryDistribution: categoryMap,
  );
});
