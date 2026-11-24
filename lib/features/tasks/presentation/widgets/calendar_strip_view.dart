import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/date_format_util.dart';
import '../../../../core/utils/haptic_feedback_util.dart';
import '../providers/task_providers.dart';

/// Horizontal interactive calendar timeline strip (14 days).
class CalendarStripView extends ConsumerWidget {
  const CalendarStripView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themePalette = ref.watch(themePaletteProvider);
    final isDark = theme.brightness == Brightness.dark;
    final selectedDate = ref.watch(selectedTimelineDateProvider);
    final tasks = ref.watch(taskListProvider);

    final now = DateTime.now();
    final days = List.generate(
      14,
      (i) => DateTime(now.year, now.month, now.day - 2 + i),
    );

    return SizedBox(
      height: 82,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final date = days[index];
          final isSelected = DateFormatUtil.isSameDay(date, selectedDate);
          final isToday = DateFormatUtil.isSameDay(date, now);

          // Check if tasks exist on this date
          final hasTasksOnDay = tasks.any((t) {
            if (t.dueDate == null) return false;
            return DateFormatUtil.isSameDay(t.dueDate!, date);
          });

          return GestureDetector(
            onTap: () {
              HapticFeedbackUtil.selection();
              ref.read(selectedTimelineDateProvider.notifier).state = date;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? themePalette.primaryColor
                    : (isToday
                        ? (isDark
                            ? themePalette.primaryContainerDarkColor
                            : themePalette.primaryContainerLightColor)
                        : (isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? themePalette.primaryColor
                      : (isToday
                          ? themePalette.primaryColor.withValues(alpha: 0.5)
                          : (isDark
                              ? AppColors.darkCardBorder
                              : AppColors.lightCardBorder)),
                  width: isSelected || isToday ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormatUtil.formatDayOfWeek(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.85)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatUtil.formatDayNumber(date),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Indicator dot for scheduled tasks
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasTasksOnDay
                          ? (isSelected ? Colors.white : AppColors.accentCoral)
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
