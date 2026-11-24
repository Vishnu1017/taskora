import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Clean 7-day weekly task completions bar chart rendered with CustomPainter.
class WeeklyBarChart extends StatelessWidget {
  final Map<int, int> weekdayCompletions; // 1=Mon .. 7=Sun -> count

  const WeeklyBarChart({super.key, required this.weekdayCompletions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final maxCount = weekdayCompletions.values.fold<int>(1, (max, v) => v > max ? v : max);

    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weekly Activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Past 7 Days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 140,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final weekday = index + 1; // 1=Mon
                  final count = weekdayCompletions[weekday] ?? 0;
                  final heightRatio = maxCount > 0 ? count / maxCount : 0.0;
                  final barHeight = (heightRatio * 90.0).clamp(6.0, 90.0);

                  final isToday = DateTime.now().weekday == weekday;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: count > 0
                              ? (isToday ? theme.colorScheme.primary : theme.colorScheme.onSurface)
                              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 22,
                        height: barHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: isToday
                              ? AppColors.primaryGradient
                              : LinearGradient(
                                  colors: count > 0
                                      ? [
                                          isDark
                                              ? const Color(0xFF3B82F6)
                                              : const Color(0xFF60A5FA),
                                          isDark
                                              ? const Color(0xFF1D4ED8)
                                              : const Color(0xFF2563EB),
                                        ]
                                      : [
                                          theme.colorScheme.surfaceContainerHighest,
                                          theme.colorScheme.surfaceContainerHighest,
                                        ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dayLabels[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                          color: isToday
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
