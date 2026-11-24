import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskora/core/theme/theme_provider.dart';
import 'package:taskora/core/utils/haptic_feedback_util.dart';
import 'package:taskora/features/tasks/domain/nlp_task_parser.dart';
import 'package:taskora/features/tasks/domain/priority_enum.dart';
import 'package:taskora/features/tasks/domain/recurrence_enum.dart';
import 'package:taskora/features/tasks/domain/task_model.dart';
import 'package:taskora/features/tasks/presentation/providers/task_providers.dart';
import 'package:uuid/uuid.dart';

/// Interactive Natural Language Task Quick-Add Bar.
/// Allows users to type naturally (e.g. "Meeting tomorrow at 3pm !urgent #Work ~45m")
/// and automatically parses date, time, priority, category, and duration in real time.
class NlpQuickAddBar extends ConsumerStatefulWidget {
  final VoidCallback? onTaskCreated;
  final bool isExpandable;
  final String hintText;

  const NlpQuickAddBar({
    super.key,
    this.onTaskCreated,
    this.isExpandable = true,
    this.hintText = "Quick Add: e.g. Finish report tomorrow at 4pm !urgent #Work ~45m",
  });

  @override
  ConsumerState<NlpQuickAddBar> createState() => _NlpQuickAddBarState();
}

class _NlpQuickAddBarState extends ConsumerState<NlpQuickAddBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  ParsedTaskResult? _parsedResult;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    if (text.trim().isEmpty) {
      if (_parsedResult != null) {
        setState(() => _parsedResult = null);
      }
      return;
    }

    final categories = ref.read(categoryListProvider);
    final result = NlpTaskParser.parse(text, availableCategories: categories);
    setState(() => _parsedResult = result);
  }

  void _createTask() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    HapticFeedbackUtil.selection();

    final categories = ref.read(categoryListProvider);
    final parsed = _parsedResult ??
        NlpTaskParser.parse(text, availableCategories: categories);

    final title = parsed.cleanTitle.isNotEmpty ? parsed.cleanTitle : text;
    final categoryId = parsed.category?.id ?? 'work';
    final priority = parsed.priority ?? TaskPriority.medium;
    final recurrence = parsed.recurrence ?? TaskRecurrence.none;
    final dueDate = parsed.combinedDueDateTime;
    final focusedMinutes = parsed.estimatedMinutes ?? 0;

    final newTask = Task(
      id: const Uuid().v4(),
      title: title,
      categoryId: categoryId,
      priority: priority,
      recurrence: recurrence,
      dueDate: dueDate,
      focusedMinutes: focusedMinutes,
      createdAt: DateTime.now(),
    );

    ref.read(taskListProvider.notifier).addTask(newTask);

    _controller.clear();
    _focusNode.unfocus();
    setState(() => _parsedResult = null);

    widget.onTaskCreated?.call();

    // Show confirmation feedback
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added "$title"',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.amberAccent,
          onPressed: () {
            ref.read(taskListProvider.notifier).deleteTask(newTask.id);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themePalette = ref.watch(themePaletteProvider);
    final isDark = theme.brightness == Brightness.dark;
    final hasTokens = _parsedResult != null && _parsedResult!.tokens.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF131728)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isFocused
              ? themePalette.primaryColor
              : (isDark
                  ? const Color(0xFF282F4D)
                  : const Color(0xFFE2E8F0)),
          width: _isFocused ? 1.6 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? themePalette.primaryColor.withValues(alpha: isDark ? 0.22 : 0.12)
                : Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: _isFocused ? 18 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Input Field Row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 8, 4),
            child: Row(
              children: [
                // AI Sparkle Indicator Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: themePalette.primaryColor.withValues(alpha: isDark ? 0.20 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: themePalette.primaryColor,
                  ),
                ),
                const SizedBox(width: 10),

                // Text Input
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _createTask(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        fontSize: 12.5,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),

                // Clear Icon Button (if typing)
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _parsedResult = null);
                    },
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Clear',
                  ),

                // Quick Send Button
                AnimatedScale(
                  scale: _controller.text.trim().isNotEmpty ? 1.0 : 0.85,
                  duration: const Duration(milliseconds: 180),
                  child: GestureDetector(
                    onTap: _controller.text.trim().isNotEmpty ? _createTask : null,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: _controller.text.trim().isNotEmpty
                            ? themePalette.gradient
                            : null,
                        color: _controller.text.trim().isEmpty
                            ? theme.colorScheme.surfaceContainerHighest
                            : null,
                        shape: BoxShape.circle,
                        boxShadow: _controller.text.trim().isNotEmpty
                            ? [
                                BoxShadow(
                                  color: themePalette.primaryColor.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          size: 18,
                          color: _controller.text.trim().isNotEmpty
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Live Auto-Detected Attribute Chips
          if (hasTokens)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 12, thickness: 0.8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _parsedResult!.tokens.map((token) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: _tokenBadgeColor(token.type, themePalette, isDark),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _tokenBorderColor(token.type, themePalette, isDark),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              token.icon,
                              size: 13,
                              color: _tokenTextColor(token.type, themePalette, isDark),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              token.displayLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _tokenTextColor(token.type, themePalette, isDark),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _tokenBadgeColor(NlpTokenType type, AppThemePalette palette, bool isDark) {
    return switch (type) {
      NlpTokenType.priority =>
        Colors.redAccent.withValues(alpha: isDark ? 0.22 : 0.12),
      NlpTokenType.category =>
        palette.primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
      NlpTokenType.date || NlpTokenType.time =>
        Colors.blueAccent.withValues(alpha: isDark ? 0.22 : 0.12),
      NlpTokenType.duration =>
        Colors.amberAccent.withValues(alpha: isDark ? 0.22 : 0.12),
      NlpTokenType.recurrence =>
        Colors.purpleAccent.withValues(alpha: isDark ? 0.22 : 0.12),
      _ => palette.primaryColor.withValues(alpha: isDark ? 0.20 : 0.10),
    };
  }

  Color _tokenBorderColor(NlpTokenType type, AppThemePalette palette, bool isDark) {
    return switch (type) {
      NlpTokenType.priority =>
        Colors.redAccent.withValues(alpha: isDark ? 0.50 : 0.35),
      NlpTokenType.category =>
        palette.primaryColor.withValues(alpha: isDark ? 0.50 : 0.35),
      NlpTokenType.date || NlpTokenType.time =>
        Colors.blueAccent.withValues(alpha: isDark ? 0.50 : 0.35),
      NlpTokenType.duration =>
        Colors.amberAccent.withValues(alpha: isDark ? 0.50 : 0.35),
      NlpTokenType.recurrence =>
        Colors.purpleAccent.withValues(alpha: isDark ? 0.50 : 0.35),
      _ => palette.primaryColor.withValues(alpha: isDark ? 0.40 : 0.30),
    };
  }

  Color _tokenTextColor(NlpTokenType type, AppThemePalette palette, bool isDark) {
    return switch (type) {
      NlpTokenType.priority => isDark ? const Color(0xFFFF6B6B) : const Color(0xFFDC2626),
      NlpTokenType.category => palette.primaryColor,
      NlpTokenType.date || NlpTokenType.time => isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
      NlpTokenType.duration => isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
      NlpTokenType.recurrence => isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA),
      _ => palette.primaryColor,
    };
  }
}
