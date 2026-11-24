import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskora/core/responsive/app_breakpoints.dart';
import 'package:taskora/core/theme/app_colors.dart';
import 'package:taskora/features/analytics/presentation/widgets/category_breakdown_chart.dart';
import 'package:taskora/features/analytics/presentation/widgets/weekly_bar_chart.dart';
import 'package:taskora/features/tasks/presentation/providers/task_providers.dart';

/// Productivity Analytics view with summary stat cards, streak indicators, and charts.
/// Responsive: 1 column on compact (<360dp), 2 columns on phones, 4 columns on tablets (>700dp).
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(productivityStatsProvider);
    final categories = ref.watch(categoryListProvider);
    final horizontalPad = context.responsiveHorizontalPadding;
    final screenWidth = context.screenWidth;

    final int crossAxisCount;
    final double childAspectRatio;

    if (screenWidth < 360) {
      crossAxisCount = 1;
      childAspectRatio = 2.8;
    } else if (screenWidth >= 720) {
      crossAxisCount = 4;
      childAspectRatio = 1.35;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 1.45;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productivity Analytics'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPad,
            vertical: 16.0,
          ),
          children: [
            // Top Grid: 4 Metric Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
              children: [
                _buildMetricCard(
                  context,
                  title: 'Completed',
                  value: '${stats.completedTasks}',
                  subtitle: '${stats.totalTasks} total tasks',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.accentEmerald,
                ),
                _buildMetricCard(
                  context,
                  title: 'Success Rate',
                  value: '${(stats.completionRate * 100).toInt()}%',
                  subtitle: 'Overall efficiency',
                  icon: Icons.pie_chart_rounded,
                  color: AppColors.primary,
                ),
                _buildMetricCard(
                  context,
                  title: 'Active Streak',
                  value: '${stats.streakDays} Days',
                  subtitle: 'Daily consistency',
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.accentAmber,
                ),
                _buildMetricCard(
                  context,
                  title: 'Focus Time',
                  value: '${stats.totalFocusedMinutes}m',
                  subtitle: 'Deep work logged',
                  icon: Icons.timer_rounded,
                  color: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Weekly Activity Bar Chart
            WeeklyBarChart(weekdayCompletions: stats.weekdayCompletions),
            const SizedBox(height: 20),

            // Category Breakdown Chart
            CategoryBreakdownChart(
              categoryDistribution: stats.categoryDistribution,
              categories: categories,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(icon, size: 18, color: color),
              ],
            ),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
