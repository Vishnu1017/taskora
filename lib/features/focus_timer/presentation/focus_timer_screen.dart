import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskora/core/responsive/app_breakpoints.dart';
import 'package:taskora/core/services/notification_service.dart';
import 'package:taskora/core/theme/app_colors.dart';
import 'package:taskora/core/utils/haptic_feedback_util.dart';
import 'package:taskora/features/focus_timer/presentation/widgets/circular_timer_painter.dart';
import 'package:taskora/features/gamification/presentation/providers/gamification_provider.dart';
import 'package:taskora/features/tasks/presentation/providers/task_providers.dart';

enum PomodoroMode {
  focus(25, 'Focus Session', false),
  shortBreak(5, 'Short Break', true),
  longBreak(15, 'Long Break', true);

  final int defaultMinutes;
  final String label;
  final bool isBreak;

  const PomodoroMode(this.defaultMinutes, this.label, this.isBreak);
}

/// Standalone built-in Focus Mode (Pomodoro Timer) screen.
/// Automatically adapts to portrait, landscape, compact phones, and wide tablets.
class FocusTimerScreen extends ConsumerStatefulWidget {
  final String? initialTaskId;

  const FocusTimerScreen({super.key, this.initialTaskId});

  @override
  ConsumerState<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends ConsumerState<FocusTimerScreen> {
  PomodoroMode _mode = PomodoroMode.focus;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  String? _selectedTaskId;

  @override
  void initState() {
    super.initState();
    _selectedTaskId = widget.initialTaskId;
    _remainingSeconds = _mode.defaultMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _switchMode(PomodoroMode newMode) {
    HapticFeedbackUtil.selection();
    _timer?.cancel();
    setState(() {
      _mode = newMode;
      _isRunning = false;
      _remainingSeconds = newMode.defaultMinutes * 60;
    });
  }

  void _toggleTimer() {
    HapticFeedbackUtil.light();
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _onTimerComplete();
        }
      });
    }
  }

  void _resetTimer() {
    HapticFeedbackUtil.light();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _mode.defaultMinutes * 60;
    });
  }

  Future<void> _onTimerComplete() async {
    _timer?.cancel();
    setState(() => _isRunning = false);

    await HapticFeedbackUtil.taskCompleted();

    // Log minutes to selected task if in focus mode
    if (!_mode.isBreak && _selectedTaskId != null) {
      ref.read(taskListProvider.notifier).addFocusedMinutes(
        _selectedTaskId!,
        _mode.defaultMinutes,
      );
    }

    // Award Gamification Focus XP and check focus trophies
    if (!_mode.isBreak) {
      final reward = await ref
          .read(gamificationProvider.notifier)
          .recordFocusSession(_mode.defaultMinutes);
      ref.read(latestGamificationRewardProvider.notifier).state = reward;
    }

    // Trigger local notification
    await NotificationService.instance.showInstantNotification(
      title: _mode.isBreak ? 'Break Complete!' : 'Focus Session Finished!',
      body: _mode.isBreak
          ? 'Ready to dive back into your flow?'
          : 'Great work! You logged ${_mode.defaultMinutes} minutes of deep focus.',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _mode.isBreak
                ? 'Break finished! Time to get back to focus.'
                : 'Session logged! ${_mode.defaultMinutes} focus minutes saved.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLandscape = context.isLandscape;
    final tasks = ref.watch(taskListProvider);
    final activeTasks = tasks.where((t) => !t.isCompleted).toList();

    final totalSeconds = _mode.defaultMinutes * 60;
    final progress = 1.0 - (_remainingSeconds / totalSeconds);

    final minutesStr = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final secondsStr = (_remainingSeconds % 60).toString().padLeft(2, '0');

    // Adapt circular timer size for compact phones or landscape mode
    final timerDimension = isLandscape
        ? (context.screenHeight * 0.45).clamp(180.0, 240.0)
        : (context.screenWidth * 0.65).clamp(200.0, 270.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mode Switcher Tabs
                  SegmentedButton<PomodoroMode>(
                    segments: PomodoroMode.values.map((m) {
                      return ButtonSegment(
                        value: m,
                        label: Text(
                          m.label,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                    selected: {_mode},
                    onSelectionChanged: (set) => _switchMode(set.first),
                  ),
                  const SizedBox(height: 24),

                  // Task Selector Card
                  if (!_mode.isBreak) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            isExpanded: true,
                            value: _selectedTaskId,
                            hint: const Row(
                              children: [
                                Icon(Icons.link_rounded, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Link to an active task...',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('No Task Linked (General Focus)'),
                              ),
                              ...activeTasks.map((t) {
                                return DropdownMenuItem<String?>(
                                  value: t.id,
                                  child: Text(
                                    t.title,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              HapticFeedbackUtil.selection();
                              setState(() => _selectedTaskId = val);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ] else
                    const SizedBox(height: 12),

                  // Circular Countdown Timer
                  SizedBox(
                    width: timerDimension,
                    height: timerDimension,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size(timerDimension, timerDimension),
                          painter: CircularTimerPainter(
                            progress: progress,
                            isBreak: _mode.isBreak,
                            isDark: isDark,
                            primaryColor: theme.colorScheme.primary,
                            secondaryColor: theme.colorScheme.secondary,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$minutesStr:$secondsStr',
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.0,
                                fontSize: timerDimension * 0.20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isRunning
                                  ? (_mode.isBreak ? 'Resting...' : 'Deep Focus...')
                                  : 'Ready',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Controls: Start/Pause, Reset
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.outlined(
                        iconSize: 26,
                        padding: const EdgeInsets.all(12),
                        onPressed: _resetTimer,
                        tooltip: 'Reset Timer',
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                      const SizedBox(width: 20),
                      FilledButton.icon(
                        onPressed: _toggleTimer,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: _mode.isBreak
                              ? AppColors.accentEmerald
                              : theme.colorScheme.primary,
                        ),
                        icon: Icon(
                          _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 26,
                        ),
                        label: Text(
                          _isRunning ? 'Pause' : 'Start Focus',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
