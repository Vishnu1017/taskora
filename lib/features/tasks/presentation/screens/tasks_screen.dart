import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskora/core/responsive/app_breakpoints.dart';
import 'package:taskora/core/theme/app_colors.dart';
import 'package:taskora/core/theme/theme_provider.dart';
import 'package:taskora/core/utils/haptic_feedback_util.dart';
import 'package:taskora/features/gamification/presentation/providers/gamification_provider.dart';
import 'package:taskora/features/gamification/presentation/widgets/celebration_confetti.dart';
import 'package:taskora/features/tasks/domain/category_model.dart';
import 'package:taskora/features/tasks/domain/task_model.dart';
import 'package:taskora/features/tasks/presentation/providers/task_providers.dart';
import 'package:taskora/features/tasks/presentation/widgets/nlp_quick_add_bar.dart';
import 'package:taskora/features/tasks/presentation/widgets/task_card.dart';

enum TasksViewMode {
  groupedList('Grouped List', Icons.view_agenda_outlined),
  kanban('Kanban Board', Icons.view_column_outlined);

  final String label;
  final IconData icon;

  const TasksViewMode(this.label, this.icon);
}

/// Dedicated Tasks Workspace screen.
/// Differentiates from the Dashboard by providing:
/// - Category Workspace Filtering (Work, Personal, Health, Study, Finance)
/// - Multi-criteria sorting (Due Date, Priority, Created, Alphabetical)
/// - View Mode Switcher: Grouped Smart List vs 3-Column Kanban Board (To Do, In Progress, Done)
class TasksScreen extends ConsumerStatefulWidget {
  final ValueChanged<Task>? onTaskSelectedForDetail;

  const TasksScreen({super.key, this.onTaskSelectedForDetail});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ConfettiController _confettiController = ConfettiController();
  TasksViewMode _viewMode = TasksViewMode.groupedList;
  String? _selectedCategoryFilter;
  bool _showCompletedSection = true;

  @override
  void dispose() {
    _searchController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themePalette = ref.watch(themePaletteProvider);
    final allTasks = ref.watch(taskListProvider);
    final categories = ref.watch(categoryListProvider);
    final sortBy = ref.watch(sortByProvider);
    final taskNotifier = ref.read(taskListProvider.notifier);
    final horizontalPad = context.responsiveHorizontalPadding;
    final isTablet = context.isTabletOrDesktop;

    // Filter by search and selected category
    final query = _searchController.text.trim().toLowerCase();
    var filtered = allTasks.where((t) {
      if (query.isNotEmpty) {
        final matchTitle = t.title.toLowerCase().contains(query);
        final matchDesc = t.description.toLowerCase().contains(query);
        final matchTag = t.tags.any((tag) => tag.toLowerCase().contains(query));
        if (!matchTitle && !matchDesc && !matchTag) return false;
      }
      if (_selectedCategoryFilter != null &&
          t.categoryId != _selectedCategoryFilter) {
        return false;
      }
      return true;
    }).toList();

    // Sort tasks
    filtered.sort((a, b) {
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

    final pendingCount = filtered.where((t) => !t.isCompleted).length;
    final completedCount = filtered.where((t) => t.isCompleted).length;

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
        }
      }
    });

    return Scaffold(
      body: ConfettiCelebrationOverlay(
        controller: _confettiController,
        palette: themePalette,
        child: SafeArea(
          child: Column(
          children: [
            // Header: Title, Active Task Count & View Switcher
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPad,
                16.0,
                horizontalPad,
                8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task Workspace',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$pendingCount active • $completedCount completed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // View Mode Toggle (Grouped List vs Kanban)
                  SegmentedButton<TasksViewMode>(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                    segments: TasksViewMode.values.map((mode) {
                      return ButtonSegment(
                        value: mode,
                        icon: Icon(mode.icon, size: 18),
                        tooltip: mode.label,
                      );
                    }).toList(),
                    selected: {_viewMode},
                    onSelectionChanged: (set) {
                      HapticFeedbackUtil.selection();
                      setState(() => _viewMode = set.first);
                    },
                  ),
                ],
              ),
            ),

            // Smart NLP Task Quick-Add Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPad,
                vertical: 4.0,
              ),
              child: const NlpQuickAddBar(
                hintText: "Quick Add: e.g. Review code tomorrow at 11am !urgent #Work",
              ),
            ),

            // Search Bar & Sort Dropdown
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPad,
                vertical: 6.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Search within workspace...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sort By Menu Button
                  PopupMenuButton<TaskSortBy>(
                    tooltip: 'Sort tasks',
                    initialValue: sortBy,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.sort_rounded, size: 20),
                    ),
                    onSelected: (sort) {
                      HapticFeedbackUtil.selection();
                      ref.read(sortByProvider.notifier).state = sort;
                    },
                    itemBuilder: (context) => TaskSortBy.values.map((sort) {
                      return PopupMenuItem(
                        value: sort,
                        child: Row(
                          children: [
                            if (sort == sortBy)
                              Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: themePalette.primaryColor,
                              )
                            else
                              const SizedBox(width: 16),
                            const SizedBox(width: 8),
                            Text('Sort by ${sort.displayName}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Category Workspace Filter Chips
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPad,
                  vertical: 4.0,
                ),
                children: [
                  ChoiceChip(
                    label: const Text('All Workspaces'),
                    selected: _selectedCategoryFilter == null,
                    selectedColor: themePalette.primaryColor,
                    labelStyle: TextStyle(
                      color: _selectedCategoryFilter == null
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontWeight: _selectedCategoryFilter == null
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                    onSelected: (val) {
                      HapticFeedbackUtil.selection();
                      setState(() => _selectedCategoryFilter = null);
                    },
                  ),
                  ...categories.map((cat) {
                    final isSelected = _selectedCategoryFilter == cat.id;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ChoiceChip(
                        avatar: Icon(
                          cat.icon,
                          size: 14,
                          color: isSelected ? Colors.white : cat.color,
                        ),
                        label: Text(cat.name),
                        selected: isSelected,
                        selectedColor: cat.color,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        onSelected: (val) {
                          HapticFeedbackUtil.selection();
                          setState(() {
                            _selectedCategoryFilter = isSelected ? null : cat.id;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Body: Grouped List or Kanban Board
            Expanded(
              child: _viewMode == TasksViewMode.groupedList
                  ? _buildGroupedListView(
                      context,
                      filtered,
                      categories,
                      horizontalPad,
                      isTablet,
                      taskNotifier,
                    )
                  : _buildKanbanBoardView(
                      context,
                      filtered,
                      categories,
                      horizontalPad,
                      isTablet,
                      taskNotifier,
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildGroupedListView(
    BuildContext context,
    List<Task> tasks,
    List<TaskCategory> categories,
    double horizontalPad,
    bool isTablet,
    TaskListNotifier taskNotifier,
  ) {
    final theme = Theme.of(context);
    final themePalette = ref.watch(themePaletteProvider);

    if (tasks.isEmpty) {
      return _buildEmptyState(theme);
    }

    // Partition tasks into smart groups
    final overdue = tasks.where((t) => t.isOverdue).toList();
    final today = tasks.where((t) => t.isDueToday && !t.isCompleted).toList();
    final upcoming = tasks.where((t) => t.isDueUpcoming && !t.isCompleted).toList();
    final noDueDate = tasks
        .where((t) => t.dueDate == null && !t.isCompleted)
        .toList();
    final completed = tasks.where((t) => t.isCompleted).toList();

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 8.0),
      children: [
        if (overdue.isNotEmpty)
          _buildTaskSection(
            context,
            title: 'Overdue',
            badgeColor: AppColors.priorityUrgent,
            tasks: overdue,
            categories: categories,
            isTablet: isTablet,
            taskNotifier: taskNotifier,
          ),
        if (today.isNotEmpty)
          _buildTaskSection(
            context,
            title: 'Due Today',
            badgeColor: themePalette.primaryColor,
            tasks: today,
            categories: categories,
            isTablet: isTablet,
            taskNotifier: taskNotifier,
          ),
        if (upcoming.isNotEmpty)
          _buildTaskSection(
            context,
            title: 'Upcoming',
            badgeColor: AppColors.secondary,
            tasks: upcoming,
            categories: categories,
            isTablet: isTablet,
            taskNotifier: taskNotifier,
          ),
        if (noDueDate.isNotEmpty)
          _buildTaskSection(
            context,
            title: 'No Due Date',
            badgeColor: theme.colorScheme.onSurfaceVariant,
            tasks: noDueDate,
            categories: categories,
            isTablet: isTablet,
            taskNotifier: taskNotifier,
          ),
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              HapticFeedbackUtil.selection();
              setState(() => _showCompletedSection = !_showCompletedSection);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(
                    _showCompletedSection
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Completed (${completed.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentEmerald,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showCompletedSection)
            ...completed.map((task) => _buildTaskCardItem(
                  context,
                  task,
                  categories,
                  isTablet,
                  taskNotifier,
                )),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTaskSection(
    BuildContext context, {
    required String title,
    required Color badgeColor,
    required List<Task> tasks,
    required List<TaskCategory> categories,
    required bool isTablet,
    required TaskListNotifier taskNotifier,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${tasks.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...tasks.map((task) => _buildTaskCardItem(
              context,
              task,
              categories,
              isTablet,
              taskNotifier,
            )),
      ],
    );
  }

  Widget _buildTaskCardItem(
    BuildContext context,
    Task task,
    List<TaskCategory> categories,
    bool isTablet,
    TaskListNotifier taskNotifier,
  ) {
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
              onPressed: () => taskNotifier.addTask(task),
            ),
          ),
        );
      },
    );
  }

  /// 3-Column Kanban Board View (To Do, In Progress, Done)
  Widget _buildKanbanBoardView(
    BuildContext context,
    List<Task> tasks,
    List<TaskCategory> categories,
    double horizontalPad,
    bool isTablet,
    TaskListNotifier taskNotifier,
  ) {
    final themePalette = ref.watch(themePaletteProvider);
    final todoTasks = tasks
        .where((t) =>
            !t.isCompleted &&
            t.subtasksCompleted == 0 &&
            t.focusedMinutes == 0)
        .toList();

    final inProgressTasks = tasks
        .where((t) =>
            !t.isCompleted &&
            (t.subtasksCompleted > 0 || t.focusedMinutes > 0))
        .toList();

    final doneTasks = tasks.where((t) => t.isCompleted).toList();

    // On tablets, display 3 side-by-side columns.
    // On phones, display horizontally scrollable swipe columns.
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 520.0;
        final columnHeight = (availableHeight - 16.0).clamp(260.0, double.infinity);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKanbanColumn(
                context,
                title: 'To Do',
                color: themePalette.primaryColor,
                tasks: todoTasks,
                categories: categories,
                isTablet: isTablet,
                taskNotifier: taskNotifier,
                columnHeight: columnHeight,
              ),
              const SizedBox(width: 12),
              _buildKanbanColumn(
                context,
                title: 'In Progress',
                color: AppColors.secondary,
                tasks: inProgressTasks,
                categories: categories,
                isTablet: isTablet,
                taskNotifier: taskNotifier,
                columnHeight: columnHeight,
              ),
              const SizedBox(width: 12),
              _buildKanbanColumn(
                context,
                title: 'Done',
                color: AppColors.accentEmerald,
                tasks: doneTasks,
                categories: categories,
                isTablet: isTablet,
                taskNotifier: taskNotifier,
                columnHeight: columnHeight,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKanbanColumn(
    BuildContext context, {
    required String title,
    required Color color,
    required List<Task> tasks,
    required List<TaskCategory> categories,
    required bool isTablet,
    required TaskListNotifier taskNotifier,
    required double columnHeight,
  }) {
    final theme = Theme.of(context);
    final isCompact = context.isCompact;
    final columnWidth = isTablet
        ? 280.0
        : (isCompact ? 250.0 : 280.0);

    return Container(
      width: columnWidth,
      height: columnHeight,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Header
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${tasks.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cards inside column
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No tasks in $title',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
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
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.format_list_bulleted_rounded,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks found in this workspace',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to create a task for this workspace.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
