import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskora/core/constants/app_constants.dart';
import 'package:taskora/core/responsive/responsive_layout_builder.dart';
import 'package:taskora/core/theme/theme_provider.dart';
import 'package:taskora/core/utils/haptic_feedback_util.dart';
import 'package:taskora/features/analytics/presentation/analytics_screen.dart';
import 'package:taskora/features/dashboard/presentation/dashboard_screen.dart';
import 'package:taskora/features/focus_timer/presentation/focus_timer_screen.dart';
import 'package:taskora/features/settings/presentation/settings_screen.dart';
import 'package:taskora/features/tasks/domain/task_model.dart';
import 'package:taskora/features/tasks/presentation/providers/task_providers.dart';
import 'package:taskora/features/tasks/presentation/screens/task_detail_screen.dart';
import 'package:taskora/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:taskora/features/tasks/presentation/widgets/modern_bottom_nav_bar.dart';
import 'package:taskora/features/tasks/presentation/widgets/task_creation_sheet.dart';

/// Primary Master-Detail Navigation Shell for Taskora.
/// Switches seamlessly between Mobile Bottom Navigation and Tablet/Desktop NavigationRail + Split View.
class MasterDetailTaskScreen extends ConsumerStatefulWidget {
  const MasterDetailTaskScreen({super.key});

  @override
  ConsumerState<MasterDetailTaskScreen> createState() =>
      _MasterDetailTaskScreenState();
}

class _MasterDetailTaskScreenState
    extends ConsumerState<MasterDetailTaskScreen> {
  int _currentTabIndex = 0;

  static const List<ModernNavItem> _modernNavItems = [
    ModernNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    ModernNavItem(
      icon: Icons.checklist_outlined,
      activeIcon: Icons.checklist_rounded,
      label: 'Tasks',
    ),
    ModernNavItem(
      icon: Icons.timer_outlined,
      activeIcon: Icons.timer_rounded,
      label: 'Focus',
    ),
    ModernNavItem(
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
      label: 'Analytics',
    ),
    ModernNavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  static const List<NavigationRailDestination> _railDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard_rounded),
      label: Text('Dashboard'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.checklist_outlined),
      selectedIcon: Icon(Icons.checklist_rounded),
      label: Text('Tasks'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.timer_outlined),
      selectedIcon: Icon(Icons.timer_rounded),
      label: Text('Focus'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.insights_outlined),
      selectedIcon: Icon(Icons.insights_rounded),
      label: Text('Analytics'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded),
      label: Text('Settings'),
    ),
  ];

  void _onTabSelected(int index) {
    HapticFeedbackUtil.selection();
    setState(() => _currentTabIndex = index);
  }

  void _openTaskCreationModal() {
    showAdaptiveTaskModal(context);
  }

  Widget _buildBodyForTab(int tabIndex, {required bool isTablet}) {
    switch (tabIndex) {
      case 0:
        return DashboardScreen(
          onTaskSelectedForDetail: isTablet
              ? (Task task) {
                  ref.read(selectedTaskForDetailProvider.notifier).state = task;
                }
              : null,
        );
      case 1:
        return TasksScreen(
          onTaskSelectedForDetail: isTablet
              ? (Task task) {
                  ref.read(selectedTaskForDetailProvider.notifier).state = task;
                }
              : null,
        );
      case 2:
        return const FocusTimerScreen();
      case 3:
        return const AnalyticsScreen();
      case 4:
        return const SettingsScreen();
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final themePalette = ref.watch(themePaletteProvider);
    final selectedDetailTask = ref.watch(selectedTaskForDetailProvider);

    final currentThemeIcon = switch (themeMode) {
      ThemeMode.system => Icons.brightness_auto_rounded,
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
    };

    return ResponsiveLayoutBuilder(
      builder: (context, info) {
        if (info.isTabletOrDesktop) {
          // Tablet / Foldable View: NavigationRail + Master-Detail Split Pane
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7.0),
                    decoration: BoxDecoration(
                      gradient: themePalette.gradient,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Text(
                    AppConstants.appName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Color Palette',
                  icon: const Icon(Icons.palette_outlined),
                  onPressed: () {
                    HapticFeedbackUtil.light();
                    _showPaletteModal(context, ref);
                  },
                ),
                IconButton(
                  tooltip: 'Toggle Theme',
                  icon: Icon(currentThemeIcon),
                  onPressed: () {
                    HapticFeedbackUtil.light();
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                ),
                const SizedBox(width: 12),
              ],
            ),
            body: Row(
              children: [
                // Left NavigationRail
                NavigationRail(
                  selectedIndex: _currentTabIndex,
                  onDestinationSelected: _onTabSelected,
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: FloatingActionButton.small(
                      onPressed: _openTaskCreationModal,
                      tooltip: 'New Task',
                      child: const Icon(Icons.add),
                    ),
                  ),
                  destinations: _railDestinations,
                ),
                const VerticalDivider(width: 1),

                // Master Left Pane (42% width)
                Expanded(
                  flex: 42,
                  child: _buildBodyForTab(_currentTabIndex, isTablet: true),
                ),
                const VerticalDivider(width: 1),

                // Detail Right Pane (58% width)
                Expanded(
                  flex: 58,
                  child: selectedDetailTask != null
                      ? TaskDetailScreen(
                          taskId: selectedDetailTask.id,
                          isEmbeddedInMasterDetail: true,
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app_outlined,
                                size: 54,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Select a task from the list',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'View subtasks, edit notes, and track progress here.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          );
        }

        // Standard Mobile Phone View (< 600dp): Bottom NavigationBar + Center FAB
        return Scaffold(
          appBar: _currentTabIndex == 0 || _currentTabIndex == 1
              ? AppBar(
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          gradient: themePalette.gradient,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        AppConstants.appName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Color Palette',
                      icon: const Icon(Icons.palette_outlined),
                      onPressed: () {
                        HapticFeedbackUtil.light();
                        _showPaletteModal(context, ref);
                      },
                    ),
                    IconButton(
                      tooltip: 'Toggle Theme',
                      icon: Icon(currentThemeIcon),
                      onPressed: () {
                        HapticFeedbackUtil.light();
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                    ),
                    const SizedBox(width: 6),
                  ],
                )
              : null,
          body: _buildBodyForTab(_currentTabIndex, isTablet: false),
          bottomNavigationBar: ModernBottomNavBar(
            selectedIndex: _currentTabIndex,
            onItemSelected: _onTabSelected,
            items: _modernNavItems,
            palette: themePalette,
          ),
          floatingActionButton: Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              gradient: themePalette.gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: themePalette.primaryColor.withValues(alpha: 0.45),
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  HapticFeedbackUtil.light();
                  _openTaskCreationModal();
                },
                child: const Center(
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPaletteModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final currentPalette = ref.watch(themePaletteProvider);
        final theme = Theme.of(context);
        final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle indicator
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme Color Palette',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Choose an aesthetic palette for Taskora',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: AppThemePalette.values.map((palette) {
                            final isSelected = currentPalette == palette;
                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                HapticFeedbackUtil.selection();
                                ref.read(themePaletteProvider.notifier).setPalette(palette);
                                Navigator.of(ctx).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? palette.primaryColor.withValues(alpha: 0.15)
                                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? palette.primaryColor
                                        : theme.colorScheme.outlineVariant,
                                    width: isSelected ? 2.0 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        gradient: palette.gradient,
                                        shape: BoxShape.circle,
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check_rounded,
                                              size: 13,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          palette.displayName,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                            color: isSelected
                                                ? palette.primaryColor
                                                : theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          palette.subtitle,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w400,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
