import 'package:taskora/core/services/local_storage_service.dart';
import 'package:taskora/core/services/notification_service.dart';
import 'package:taskora/features/tasks/domain/category_model.dart';
import 'package:taskora/features/tasks/domain/task_model.dart';

/// Repository orchestrating task persistence and scheduled local notifications.
class TaskRepository {
  final LocalStorageService _storage;
  final NotificationService _notifications;

  TaskRepository({
    required LocalStorageService storage,
    required NotificationService notifications,
  })  : _storage = storage,
        _notifications = notifications;

  Future<List<Task>> getTasks() => _storage.loadTasks();

  Future<void> saveTasks(List<Task> tasks) => _storage.saveTasks(tasks);

  Future<List<TaskCategory>> getCategories() => _storage.loadCategories();

  Future<void> saveCategories(List<TaskCategory> categories) =>
      _storage.saveCategories(categories);

  Future<void> scheduleNotification(Task task) =>
      _notifications.scheduleTaskReminder(task);

  Future<void> cancelNotification(String taskId) =>
      _notifications.cancelTaskReminder(taskId);

  Future<List<Task>> resetToSampleTasks() => _storage.resetToSampleTasks();

  Future<List<Task>> clearCompletedTasks() => _storage.clearCompletedTasks();

  String exportBackup(List<Task> tasks, List<TaskCategory> categories) =>
      _storage.exportBackupJson(tasks, categories);

  ({List<Task> tasks, List<TaskCategory> categories})? importBackup(
    String rawJson,
  ) =>
      _storage.importBackupJson(rawJson);
}
