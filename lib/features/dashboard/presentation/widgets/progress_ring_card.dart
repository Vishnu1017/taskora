import 'package:flutter/material.dart';
import 'package:taskora/core/theme/app_colors.dart';
import 'package:taskora/features/tasks/presentation/providers/task_providers.dart';

/// Animated daily progress ring card featuring responsive circular progress and auto-fitting percentage text.
/// Engineered with LayoutBuilder and FittedBox to adapt seamlessly across all device sizes (compact, phones, tablets, foldables).
class ProgressRingCard extends StatelessWidget {
  final ProductivityStats stats;

  const ProgressRingCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final targetProgress = stats.completionRate.clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: isDark
                ? const [
                    Color(0xFF16192E),
                    Color(0xFF111322),
                  ]
                : const [
                    Color(0xFFFFFFFF),
                    Color(0xFFF6F8FD),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;

          // Responsive ring dimension & stroke thickness based on container width
          final double ringSize;
          final double strokeWidth;
          final double spacing;
          final EdgeInsets cardPadding;

          if (availableWidth < 320) {
            ringSize = 62.0;
            strokeWidth = 5.5;
            spacing = 12.0;
            cardPadding = const EdgeInsets.all(12.0);
          } else if (availableWidth < 420) {
            ringSize = 72.0;
            strokeWidth = 6.5;
            spacing = 16.0;
            cardPadding = const EdgeInsets.all(16.0);
          } else if (availableWidth >= 650) {
            ringSize = 84.0;
            strokeWidth = 8.0;
            spacing = 22.0;
            cardPadding = const EdgeInsets.all(20.0);
          } else {
            ringSize = 76.0;
            strokeWidth = 7.0;
            spacing = 18.0;
            cardPadding = const EdgeInsets.all(18.0);
          }

          final isUltraNarrow = availableWidth < 290;

          return Padding(
            padding: cardPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Responsive Animated Circular Progress Indicator + Fitted %
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: targetProgress),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedValue, _) {
                    final percentage = (animatedValue * 100).toInt();
                    final isComplete = animatedValue >= 0.999;

                    return SizedBox(
                      width: ringSize,
                      height: ringSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Circular Progress Ring
                          SizedBox(
                            width: ringSize,
                            height: ringSize,
                            child: CircularProgressIndicator(
                              value: animatedValue,
                              strokeWidth: strokeWidth,
                              strokeCap: StrokeCap.round,
                              backgroundColor: theme
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.6),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isComplete
                                    ? AppColors.accentEmerald
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ),

                          // Centered Percentage Label with FittedBox
                          // Ensures % text scales smoothly without ever overflowing or clipping
                          Padding(
                            padding: EdgeInsets.all(strokeWidth + 3.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Text(
                                '$percentage%',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: isComplete
                                      ? AppColors.accentEmerald
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(width: spacing),

                // Text Content & Daily Streak Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Row: "Daily Momentum" + Streak Badge
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6.0,
                        runSpacing: 4.0,
                        children: [
                          Text(
                            'Daily Momentum',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: isUltraNarrow ? 13 : 15,
                            ),
                          ),
                          // Streak badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentAmber.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '🔥',
                                  style: TextStyle(fontSize: 11),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${stats.streakDays}d Streak',
                                  style: const TextStyle(
                                    color: AppColors.accentAmber,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Task Completion Ratio
                      Text(
                        '${stats.completedTasks} of ${stats.totalTasks} tasks completed',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: isUltraNarrow ? 12 : 13.5,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Motivational Subtitle
                      Text(
                        stats.pendingTasks == 0 && stats.totalTasks > 0
                            ? '✨ All clear for today! Outstanding work.'
                            : '${stats.pendingTasks} tasks remaining to crush today.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: stats.pendingTasks == 0
                              ? AppColors.accentEmerald
                              : theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: isUltraNarrow ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}
