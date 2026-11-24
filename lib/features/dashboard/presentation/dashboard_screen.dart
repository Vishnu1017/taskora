import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskora/core/responsive/app_breakpoints.dart';
import 'package:taskora/core/theme/theme_provider.dart';
import 'package:taskora/core/utils/date_format_util.dart';
import 'package:taskora/core/utils/haptic_feedback_util.dart';
import 'package:taskora/features/dashboard/presentation/widgets/progress_ring_card.dart';
import 'package:taskora/features/dashboard/presentation/widgets/quick_filter_chips.dart';
import 'package:taskora/features/gamification/presentation/providers/gamification_provider.dart';
import 'package:taskora/features/gamification/presentation/widgets/celebration_confetti.dart';
import 'package:taskora/features/gamification/presentation/widgets/streak_level_card.dart';
import 'package:taskora/features/tasks/domain/task_model.dart';
import 'package:taskora/features/tasks/presentation/providers/task_providers.dart';
import 'package:taskora/features/tasks/presentation/widgets/calendar_strip_view.dart';
import 'package:taskora/features/tasks/presentation/widgets/nlp_quick_add_bar.dart';
import 'package:taskora/features/tasks/presentation/widgets/task_card.dart';

/// Smart Dashboard View: Greeting, daily progress ring, quick-filter chips,
/// search bar, calendar timeline toggle, and responsive task list.
class DashboardScreen extends ConsumerStatefulWidget {
  final ValueChanged<Task>? onTaskSelectedForDetail;

  const DashboardScreen({super.key, this.onTaskSelectedForDetail});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ConfettiController _confettiController = ConfettiController();
  bool _showCalendarTimeline = false;

  @override
  void dispose() {
    _searchController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning, Explorer ☀️';
    if (hour < 17) return 'Good Afternoon, Achiever ⚡';
    return 'Good Evening, Master 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = ref.watch(themePaletteProvider);
    final stats = ref.watch(productivityStatsProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final categories = ref.watch(categoryListProvider);
    final selectedTimelineDate = ref.watch(selectedTimelineDateProvider);
    final taskNotifier = ref.read(taskListProvider.notifier);
    final horizontalPad = context.responsiveHorizontalPadding;
    final isTablet = context.isTabletOrDesktop;

    // Listen to gamification reward events for celebrations & toasts
    ref.listen<GamificationRewardEvent?>(latestGamificationRewardProvider,
        (previous, next) {
      if (next != null) {
        _confettiController.play();
        if (next.unlockedBadge != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFFFD700),
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Trophy Unlocked: ${next.unlockedBadge!.title}!',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${next.unlockedBadge!.description} (+${next.unlockedBadge!.xpReward} XP)',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF1E293B),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (next.leveledUp) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    '🎉 LEVEL UP! You reached Level ${next.newLevel}!',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              backgroundColor: palette.primaryColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    });

    // If calendar timeline is active, filter tasks for the selected date
    final displayedTasks = _showCalendarTimeline
        ? filteredTasks.where((t) {
            if (t.dueDate == null) return false;
            return DateFormatUtil.isSameDay(t.dueDate!, selectedTimelineDate);
          }).toList()
        : filteredTasks;

    return ConfettiCelebrationOverlay(
      controller: _confettiController,
      palette: palette,
      child: RefreshIndicator(
        onRefresh: () async {
          await HapticFeedbackUtil.light();
        },
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPad,
            vertical: 16.0,
          ),
          children: [
            // Greeting Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatUtil.formatFullDate(DateTime.now()),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                // Focus Mode Quick Launcher
                IconButton.filledTonal(
                  tooltip: 'Quick Focus Timer',
                  onPressed: () {
                    HapticFeedbackUtil.light();
                    context.push('/focus');
                  },
                  icon: const Icon(Icons.timer_outlined),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Daily Streak & Level Gamification Banner
            const StreakLevelCard(),
            const SizedBox(height: 14),

            // Daily Progress Ring Card
            ProgressRingCard(stats: stats),
            const SizedBox(height: 18),

          // Smart Natural Language Quick-Add Bar
          const NlpQuickAddBar(),
          const SizedBox(height: 14),

          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search tasks, subtasks, tags...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (query) {
              ref.read(searchQueryProvider.notifier).state = query;
              setState(() {});
            },
          ),
          const SizedBox(height: 16),

          // Quick Filter Pills
          const QuickFilterChips(),
          const SizedBox(height: 16),

          // View Toggle: List View vs Calendar Timeline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _showCalendarTimeline ? 'Timeline Schedule' : 'Tasks List',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  HapticFeedbackUtil.selection();
                  setState(() => _showCalendarTimeline = !_showCalendarTimeline);
                },
                icon: Icon(
                  _showCalendarTimeline
                      ? Icons.list_rounded
                      : Icons.calendar_view_week_rounded,
                  size: 18,
                ),
                label: Text(
                  _showCalendarTimeline ? 'Show List' : 'Calendar View',
                ),
              ),
            ],
          ),

          // Horizontal Calendar Strip if active
          if (_showCalendarTimeline) ...[
            const SizedBox(height: 8),
            const CalendarStripView(),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 8),

          // Tasks List
          if (displayedTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48.0),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.done_all_rounded,
                        size: 44,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks matching this filter',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap + to create a new task or pick another filter.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...displayedTasks.map((task) {
              final cat = categories.cast<dynamic>().firstWhere(
                (c) => c.id == task.categoryId,
                orElse: () => null,
              );

              return TaskCard(
                task: task,
                category: cat,
                onTap: () {
                  HapticFeedbackUtil.light();
                  if (isTablet && widget.onTaskSelectedForDetail != null) {
                    widget.onTaskSelectedForDetail!(task);
                  } else {
                    context.push('/task-detail/${task.id}');
                  }
                },
                onToggleComplete: () {
                  taskNotifier.toggleTaskCompletion(task.id);
                },
                onDelete: () {
                  taskNotifier.deleteTask(task.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Deleted "${task.title}"'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          taskNotifier.addTask(task);
                        },
                      ),
                    ),
                  );
                },
              );
            }),

          const SizedBox(height: 80),
        ],
      ),
    ),
  );
}
}
