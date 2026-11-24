import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskora/core/theme/app_colors.dart';
import 'package:taskora/core/utils/date_format_util.dart';
import 'package:taskora/core/utils/haptic_feedback_util.dart';
import 'package:taskora/features/tasks/domain/recurrence_enum.dart';
import 'package:taskora/features/tasks/presentation/providers/task_providers.dart';
import 'package:taskora/features/tasks/presentation/widgets/subtask_checklist_widget.dart';
import 'package:taskora/features/tasks/presentation/widgets/task_creation_sheet.dart';

/// Full Task Detail view.
/// Can be presented as a standalone screen or embedded in tablet Master-Detail pane.
class TaskDetailScreen extends ConsumerWidget {
  final String taskId;
  final bool isEmbeddedInMasterDetail;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    this.isEmbeddedInMasterDetail = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tasks = ref.watch(taskListProvider);
    final categories = ref.watch(categoryListProvider);

    final taskIndex = tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) {
      return Scaffold(
        appBar: isEmbeddedInMasterDetail ? null : AppBar(),
        body: const Center(child: Text('Task not found or was deleted.')),
      );
    }

    final task = tasks[taskIndex];
    final category = categories.cast<dynamic>().firstWhere(
      (c) => c.id == task.categoryId,
      orElse: () => null,
    );
    final taskNotifier = ref.read(taskListProvider.notifier);

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header badges: Priority, Category, Status
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Priority badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: task.priority.containerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(task.priority.icon, size: 14, color: task.priority.color),
                    const SizedBox(width: 4),
                    Text(
                      task.priority.displayName,
                      style: TextStyle(
                        color: task.priority.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Category badge
              if (category != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(category.icon, size: 14, color: category.color),
                      const SizedBox(width: 4),
                      Text(
                        category.name,
                        style: TextStyle(
                          color: category.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

              // Quick Focus Timer Launch button
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedbackUtil.light();
                  context.push('/focus?taskId=${task.id}');
                },
                icon: const Icon(Icons.timer_outlined, size: 16),
                label: const Text('Focus'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Title
          Text(
            task.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          if (task.description.isNotEmpty) ...[
            Text(
              task.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Quick Schedule Metadata Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'Due Date:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormatUtil.formatRelative(task.dueDate),
                        style: TextStyle(
                          color: task.isOverdue
                              ? AppColors.priorityUrgent
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (task.reminderTime != null) ...[
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.notifications_active_outlined, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          'Reminder:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormatUtil.formatRelative(task.reminderTime),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                  if (task.recurrence != TaskRecurrence.none) ...[
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.repeat_rounded, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          'Recurrence:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          task.recurrence.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                  if (task.focusedMinutes > 0) ...[
                    const Divider(height: 20),
                    Row(
                      children: [
                        Icon(Icons.timer_rounded, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 10),
                        Text(
                          'Focused Time Logged:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${task.focusedMinutes} minutes',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Interactive Subtasks/Checklist
          SubtaskChecklistWidget(
            subtasks: task.subtasks,
            onToggleSubtask: (subtaskId) {
              taskNotifier.toggleSubtaskCompletion(task.id, subtaskId);
            },
            onAddSubtask: (subtaskTitle) {
              taskNotifier.addSubtask(task.id, subtaskTitle);
            },
            onDeleteSubtask: (subtaskId) {
              taskNotifier.deleteSubtask(task.id, subtaskId);
            },
          ),
          const SizedBox(height: 36),

          // Action Buttons: Complete Toggle & Delete
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    taskNotifier.toggleTaskCompletion(task.id);
                  },
                  icon: Icon(
                    task.isCompleted
                        ? Icons.replay_rounded
                        : Icons.check_circle_rounded,
                  ),
                  label: Text(
                    task.isCompleted ? 'Mark Incomplete' : 'Complete Task',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: task.isCompleted
                        ? theme.colorScheme.surfaceContainerHighest
                        : theme.colorScheme.primary,
                    foregroundColor: task.isCompleted
                        ? theme.colorScheme.onSurface
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.outlined(
                tooltip: 'Edit Task',
                onPressed: () {
                  showAdaptiveTaskModal(context, taskToEdit: task);
                },
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton.outlined(
                tooltip: 'Delete Task',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Task?'),
                      content: Text('Are you sure you want to delete "${task.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.priorityUrgent,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await taskNotifier.deleteTask(task.id);
                    if (!isEmbeddedInMasterDetail && context.mounted) {
                      context.pop();
                    }
                  }
                },
                icon: const Icon(Icons.delete_outline_rounded),
                color: AppColors.priorityUrgent,
              ),
            ],
          ),
        ],
      ),
    );

    if (isEmbeddedInMasterDetail) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              showAdaptiveTaskModal(context, taskToEdit: task);
            },
          ),
        ],
      ),
      body: content,
    );
  }
}
