import 'package:flutter/material.dart';
import 'package:taskora/core/theme/app_colors.dart';
import 'package:taskora/core/theme/app_theme.dart';
import 'package:taskora/core/utils/date_format_util.dart';
import 'package:taskora/core/utils/haptic_feedback_util.dart';
import 'package:taskora/features/tasks/domain/category_model.dart';
import 'package:taskora/features/tasks/domain/priority_enum.dart';
import 'package:taskora/features/tasks/domain/recurrence_enum.dart';
import 'package:taskora/features/tasks/domain/task_model.dart';

/// Reusable Task Card with swipe gestures, haptics, priority indicator, and subtasks progress.
/// Engineered with Wrap and flexible layout to prevent RenderFlex overflow across all screen sizes.
class TaskCard extends StatelessWidget {
  final Task task;
  final TaskCategory? category;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final bool isSelectedInMasterDetail;

  const TaskCard({
    super.key,
    required this.task,
    this.category,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
    this.isSelectedInMasterDetail = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskoraColors = context.taskoraColors;

    final priorityColor = task.priority.color;
    final catColor = category?.color ?? theme.colorScheme.primary;

    return Dismissible(
      key: Key('task-${task.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right to toggle completion
          onToggleComplete();
          return false;
        } else {
          // Swipe left to delete
          HapticFeedbackUtil.heavy();
          onDelete();
          return true;
        }
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.accentEmerald.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        child: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Complete',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.priorityUrgent.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isSelectedInMasterDetail
                ? theme.colorScheme.primary
                : taskoraColors.cardBorder,
            width: isSelectedInMasterDetail ? 2.0 : 1.0,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom interactive checkbox
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: GestureDetector(
                    onTap: onToggleComplete,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: task.isCompleted
                              ? theme.colorScheme.primary
                              : priorityColor,
                          width: 2.0,
                        ),
                      ),
                      child: task.isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Main Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges: Wrapped flexibly to prevent horizontal overflow on narrow screens
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Category badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              category?.name ?? 'General',
                              style: TextStyle(
                                color: catColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // Priority tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: switch (task.priority) {
                                TaskPriority.urgent => taskoraColors.urgentPriorityContainer,
                                TaskPriority.high => taskoraColors.highPriorityContainer,
                                TaskPriority.medium => taskoraColors.mediumPriorityContainer,
                                TaskPriority.low => taskoraColors.lowPriorityContainer,
                              },
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: priorityColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  task.priority.displayName,
                                  style: TextStyle(
                                    color: priorityColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (task.recurrence != TaskRecurrence.none)
                            Icon(
                              Icons.repeat_rounded,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),

                          if (task.reminderTime != null)
                            const Icon(
                              Icons.notifications_active_outlined,
                              size: 14,
                              color: AppColors.accentAmber,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Task Title
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurface,
                        ),
                      ),

                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Footer: Due Date, Subtask progress, Focus time
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (task.dueDate != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 14,
                                  color: task.isOverdue
                                      ? AppColors.priorityUrgent
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormatUtil.formatRelative(task.dueDate),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: task.isOverdue
                                        ? AppColors.priorityUrgent
                                        : theme.colorScheme.onSurfaceVariant,
                                    fontWeight: task.isOverdue
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),

                          if (task.subtasksTotal > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.checklist_rounded,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${task.subtasksCompleted}/${task.subtasksTotal}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),

                          if (task.focusedMinutes > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 12,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${task.focusedMinutes}m',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
