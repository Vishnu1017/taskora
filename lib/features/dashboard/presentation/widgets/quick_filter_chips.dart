import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/haptic_feedback_util.dart';
import '../../../tasks/presentation/providers/task_providers.dart';

/// Horizontally scrollable quick-filter pills for the dashboard.
/// Fully synchronized with the active [AppThemePalette].
class QuickFilterChips extends ConsumerWidget {
  const QuickFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themePalette = ref.watch(themePaletteProvider);
    final selectedFilter = ref.watch(selectedFilterProvider);
    final allTasks = ref.watch(taskListProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: TaskFilter.values.map((filter) {
          final isSelected = selectedFilter == filter;

          // Calculate badge count
          final count = switch (filter) {
            TaskFilter.all => allTasks.length,
            TaskFilter.today =>
              allTasks.where((t) => t.isDueToday && !t.isCompleted).length,
            TaskFilter.upcoming =>
              allTasks.where((t) => t.isDueUpcoming && !t.isCompleted).length,
            TaskFilter.highPriority => allTasks
                .where((t) =>
                    (t.priority.name == 'urgent' || t.priority.name == 'high') &&
                    !t.isCompleted)
                .length,
            TaskFilter.overdue => allTasks.where((t) => t.isOverdue).length,
            TaskFilter.completed => allTasks.where((t) => t.isCompleted).length,
          };

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              avatar: Icon(
                filter.icon,
                size: 15,
                color: isSelected ? Colors.white : themePalette.primaryColor,
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(filter.displayName),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.28)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              selectedColor: themePalette.primaryColor,
              backgroundColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.4),
              side: BorderSide(
                color: isSelected
                    ? themePalette.primaryColor
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                width: isSelected ? 1.5 : 1.0,
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
              onSelected: (val) {
                HapticFeedbackUtil.selection();
                ref.read(selectedFilterProvider.notifier).state = filter;
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
