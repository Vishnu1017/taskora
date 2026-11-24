import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskora/core/constants/app_constants.dart';
import 'package:taskora/core/responsive/app_breakpoints.dart';
import 'package:taskora/core/services/notification_service.dart';
import 'package:taskora/core/theme/theme_provider.dart';
import 'package:taskora/core/utils/haptic_feedback_util.dart';
import 'package:taskora/features/settings/presentation/providers/settings_provider.dart';
import 'package:taskora/features/tasks/data/task_repository.dart';
import 'package:taskora/features/tasks/presentation/providers/task_providers.dart';

/// Settings & Data Management screen for Taskora.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final themePalette = ref.watch(themePaletteProvider);
    final tasks = ref.watch(taskListProvider);
    final categories = ref.watch(categoryListProvider);
    final repository = ref.watch(taskRepositoryProvider);
    final hapticsEnabled = ref.watch(hapticsEnabledProvider);
    final horizontalPad = context.responsiveHorizontalPadding;
    final isDark = theme.brightness == Brightness.dark;
    final testChipTextColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPad,
            vertical: 16.0,
          ),
          children: [
            // Theme Mode Section
            _buildSectionHeader(context, 'Appearance & Theme'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('System Auto-Detect'),
                    subtitle: const Text('Follow device system appearance'),
                    leading: const Icon(Icons.brightness_auto_rounded),
                    trailing: themeMode == ThemeMode.system
                        ? Icon(Icons.check_rounded,
                            color: theme.colorScheme.primary)
                        : null,
                    onTap: () {
                      HapticFeedbackUtil.medium();
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(ThemeMode.system);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Light Mode'),
                    subtitle:
                        const Text('Clean pearl slate & luminous accents'),
                    leading: const Icon(Icons.light_mode_rounded),
                    trailing: themeMode == ThemeMode.light
                        ? Icon(Icons.check_rounded,
                            color: theme.colorScheme.primary)
                        : null,
                    onTap: () {
                      HapticFeedbackUtil.medium();
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(ThemeMode.light);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text(
                        'Deep velvet obsidian contrast for night focus'),
                    leading: const Icon(Icons.dark_mode_rounded),
                    trailing: themeMode == ThemeMode.dark
                        ? Icon(Icons.check_rounded,
                            color: theme.colorScheme.primary)
                        : null,
                    onTap: () {
                      HapticFeedbackUtil.medium();
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(ThemeMode.dark);
                    },
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notifications & Reminders
            _buildSectionHeader(context, 'Alerts & Notifications'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications_active_rounded),
                    title: const Text('Notification Permissions'),
                    subtitle: const Text(
                        'Ensure scheduled task reminders arrive on time'),
                    trailing: FilledButton.tonal(
                      onPressed: () async {
                        HapticFeedbackUtil.light();
                        final granted = await NotificationService.instance
                            .requestPermissions();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                granted
                                    ? 'Notification permissions enabled!'
                                    : 'Please allow notifications in system settings.',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Check'),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      hapticsEnabled
                          ? Icons.vibration_rounded
                          : Icons.phone_android_rounded,
                      color: hapticsEnabled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    title: const Text('Haptic Micro-Interactions'),
                    subtitle: Text(
                      hapticsEnabled
                          ? 'Active tactile clicks on tasks, buttons, and completions'
                          : 'Haptics muted across the application',
                    ),
                    trailing: Switch.adaptive(
                      value: hapticsEnabled,
                      activeTrackColor: theme.colorScheme.primary,
                      onChanged: (val) {
                        ref
                            .read(hapticsEnabledProvider.notifier)
                            .setEnabled(val);
                      },
                    ),
                    onTap: () {
                      ref.read(hapticsEnabledProvider.notifier).toggle();
                    },
                  ),
                  if (hapticsEnabled) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Test Haptics:',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: testChipTextColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              ActionChip(
                                avatar: Icon(
                                  Icons.touch_app_outlined,
                                  size: 14,
                                  color: testChipTextColor,
                                ),
                                label: Text(
                                  'Light Impact',
                                  style: TextStyle(
                                    color: testChipTextColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                visualDensity: VisualDensity.compact,
                                onPressed: () => HapticFeedbackUtil.light(),
                              ),
                              ActionChip(
                                avatar: Icon(
                                  Icons.vibration_rounded,
                                  size: 14,
                                  color: testChipTextColor,
                                ),
                                label: Text(
                                  'Medium Impact',
                                  style: TextStyle(
                                    color: testChipTextColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                visualDensity: VisualDensity.compact,
                                onPressed: () => HapticFeedbackUtil.medium(),
                              ),
                              ActionChip(
                                avatar: Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 14,
                                  color: testChipTextColor,
                                ),
                                label: Text(
                                  'Task Pulse',
                                  style: TextStyle(
                                    color: testChipTextColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                visualDensity: VisualDensity.compact,
                                onPressed: () =>
                                    HapticFeedbackUtil.taskCompleted(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Data Control & Backup
            _buildSectionHeader(context, 'Data Control & Offline Storage'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.cloud_download_outlined),
                    title: const Text('Export JSON Backup'),
                    subtitle: const Text(
                        'Export all tasks and categories as JSON text'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      HapticFeedbackUtil.light();
                      final jsonString =
                          repository.exportBackup(tasks, categories);
                      Clipboard.setData(ClipboardData(text: jsonString));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Backup JSON copied to clipboard!'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cloud_upload_outlined),
                    title: const Text('Import JSON Backup'),
                    subtitle: const Text(
                        'Restore tasks from a JSON clipboard backup'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showImportDialog(context, ref, repository),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cleaning_services_rounded),
                    title: const Text('Clear Completed Tasks'),
                    subtitle: const Text('Remove finished tasks from the list'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showClearCompletedDialog(context, ref),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.restart_alt_rounded),
                    title: const Text('Reset to Default Tasks'),
                    subtitle:
                        const Text('Restore clean default sample dataset'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showResetSampleDialog(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App About
            _buildSectionHeader(context, 'About Taskora'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: themePalette.gradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 16),
                    ),
                    title: const Text('Taskora Mobile'),
                    subtitle: const Text('Version 1.0.0 (Production Build)'),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '${AppConstants.appTagline}. Engineered with Flutter & Dart strict null-safety, Clean Architecture, and Riverpod.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  void _showImportDialog(
    BuildContext context,
    WidgetRef ref,
    TaskRepository repository,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Backup JSON'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paste your previously exported Taskora JSON data below to restore:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '{"version": "1.0.0", "tasks": [...]}',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final text = controller.text.trim();
              final result = repository.importBackup(text);
              if (result != null) {
                await ref
                    .read(taskListProvider.notifier)
                    .reloadFromImport(result.tasks);
                await ref
                    .read(categoryListProvider.notifier)
                    .reloadFromImport(result.categories);
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Successfully imported ${result.tasks.length} tasks!'),
                    ),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Invalid JSON format. Please verify backup payload.'),
                    ),
                  );
                }
              }
            },
            child: const Text('Import & Restore'),
          ),
        ],
      ),
    );
  }

  void _showClearCompletedDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Completed Tasks'),
        content: const Text(
          'Are you sure you want to remove all completed tasks from your workspace?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(taskListProvider.notifier).clearCompletedTasks();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Completed tasks cleared.')),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showResetSampleDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset to Default Tasks'),
        content: const Text(
          'This will reset your tasks to the clean initial sample dataset. Any custom tasks created will be replaced.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(taskListProvider.notifier).resetToSampleTasks();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Tasks reset to clean sample dataset.')),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
