import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskora/core/responsive/app_breakpoints.dart';
import 'package:taskora/core/theme/theme_provider.dart';
import 'package:taskora/core/utils/date_format_util.dart';
import 'package:taskora/core/utils/haptic_feedback_util.dart';
import 'package:taskora/features/tasks/domain/nlp_task_parser.dart';
import 'package:taskora/features/tasks/domain/priority_enum.dart';
import 'package:taskora/features/tasks/domain/recurrence_enum.dart';
import 'package:taskora/features/tasks/domain/subtask_model.dart';
import 'package:taskora/features/tasks/domain/task_model.dart';
import 'package:taskora/features/tasks/presentation/providers/task_providers.dart';
import 'package:uuid/uuid.dart';

/// Launches TaskCreationSheet adaptively:
/// As a centered, width-constrained Dialog on Tablets & Foldables (>=600dp),
/// and as an ergonomic full/half modal bottom sheet on Mobile Phones (<600dp).
Future<void> showAdaptiveTaskModal(
  BuildContext context, {
  Task? taskToEdit,
}) async {
  HapticFeedbackUtil.light();
  if (context.isTabletOrDesktop) {
    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: TaskCreationSheet(taskToEdit: taskToEdit),
          ),
        ),
      ),
    );
  } else {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => TaskCreationSheet(taskToEdit: taskToEdit),
    );
  }
}

/// Modal bottom sheet / dialog for creating or editing a comprehensive task.
class TaskCreationSheet extends ConsumerStatefulWidget {
  final Task? taskToEdit;

  const TaskCreationSheet({super.key, this.taskToEdit});

  @override
  ConsumerState<TaskCreationSheet> createState() => _TaskCreationSheetState();
}

class _TaskCreationSheetState extends ConsumerState<TaskCreationSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _subtaskInputController;

  late TaskPriority _selectedPriority;
  late String _selectedCategoryId;
  late TaskRecurrence _selectedRecurrence;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  bool _enableReminder = false;
  late List<Subtask> _subtasks;
  bool _isAddingSubtask = false;
  ParsedTaskResult? _nlpResult;

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _titleController.addListener(_onTitleChanged);
    _descController = TextEditingController(text: task?.description ?? '');
    _subtaskInputController = TextEditingController();

    _selectedPriority = task?.priority ?? TaskPriority.medium;
    _selectedCategoryId = task?.categoryId ?? 'work';
    _selectedRecurrence = task?.recurrence ?? TaskRecurrence.none;
    _selectedDueDate = task?.dueDate;
    if (task?.dueDate != null) {
      _selectedDueTime = TimeOfDay.fromDateTime(task!.dueDate!);
    }
    _enableReminder = task?.reminderTime != null;
    _subtasks = task?.subtasks.toList() ?? [];
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _descController.dispose();
    _subtaskInputController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    final text = _titleController.text;
    if (text.trim().isEmpty) {
      if (_nlpResult != null) {
        setState(() => _nlpResult = null);
      }
      return;
    }

    final categories = ref.read(categoryListProvider);
    final result = NlpTaskParser.parse(text, availableCategories: categories);
    setState(() => _nlpResult = result);
  }

  void _applyNlpDetectedAttributes() {
    if (_nlpResult == null) return;
    HapticFeedbackUtil.selection();
    setState(() {
      if (_nlpResult!.dueDate != null) {
        _selectedDueDate = _nlpResult!.dueDate;
      }
      if (_nlpResult!.dueTime != null) {
        _selectedDueTime = _nlpResult!.dueTime;
      }
      if (_nlpResult!.priority != null) {
        _selectedPriority = _nlpResult!.priority!;
      }
      if (_nlpResult!.category != null) {
        _selectedCategoryId = _nlpResult!.category!.id;
      }
      if (_nlpResult!.recurrence != null) {
        _selectedRecurrence = _nlpResult!.recurrence!;
      }
      if (_nlpResult!.cleanTitle.isNotEmpty) {
        _titleController.text = _nlpResult!.cleanTitle;
        _titleController.selection = TextSelection.fromPosition(
          TextPosition(offset: _titleController.text.length),
        );
      }
      _nlpResult = null;
    });
  }

  void _onQuickDateSelect(int offsetDays) {
    HapticFeedbackUtil.selection();
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day + offsetDays);
    setState(() {
      _selectedDueDate = target;
      _selectedDueTime ??= const TimeOfDay(hour: 17, minute: 0);
    });
  }

  Future<void> _pickCustomDate() async {
    HapticFeedbackUtil.light();
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedDueTime ?? TimeOfDay.now(),
      );

      if (mounted) {
        setState(() {
          _selectedDueDate = pickedDate;
          if (pickedTime != null) {
            _selectedDueTime = pickedTime;
          }
        });
      }
    }
  }

  void _addSubtask() {
    final title = _subtaskInputController.text.trim();
    if (title.isNotEmpty) {
      HapticFeedbackUtil.light();
      setState(() {
        _subtasks.add(
          Subtask(
            id: const Uuid().v4(),
            title: title,
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
        );
        _subtaskInputController.clear();
        _isAddingSubtask = false;
      });
    }
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    var finalTitle = title;
    var finalPriority = _selectedPriority;
    var finalCategoryId = _selectedCategoryId;
    var finalRecurrence = _selectedRecurrence;
    DateTime? finalDue;
    if (_selectedDueDate != null) {
      final time = _selectedDueTime ?? const TimeOfDay(hour: 12, minute: 0);
      finalDue = DateTime(
        _selectedDueDate!.year,
        _selectedDueDate!.month,
        _selectedDueDate!.day,
        time.hour,
        time.minute,
      );
    }
    var finalFocusedMinutes = widget.taskToEdit?.focusedMinutes ?? 0;

    // Automatically apply unapplied NLP detected attributes
    if (_nlpResult != null && _nlpResult!.hasAnyAttributes) {
      if (_nlpResult!.cleanTitle.isNotEmpty) {
        finalTitle = _nlpResult!.cleanTitle;
      }
      if (finalDue == null && _nlpResult!.combinedDueDateTime != null) {
        finalDue = _nlpResult!.combinedDueDateTime;
      }
      if (finalPriority == TaskPriority.medium && _nlpResult!.priority != null) {
        finalPriority = _nlpResult!.priority!;
      }
      if (finalCategoryId == 'work' && _nlpResult!.category != null) {
        finalCategoryId = _nlpResult!.category!.id;
      }
      if (finalRecurrence == TaskRecurrence.none && _nlpResult!.recurrence != null) {
        finalRecurrence = _nlpResult!.recurrence!;
      }
      if (finalFocusedMinutes == 0 && _nlpResult!.estimatedMinutes != null) {
        finalFocusedMinutes = _nlpResult!.estimatedMinutes!;
      }
    }

    DateTime? reminder;
    if (_enableReminder && finalDue != null) {
      reminder = finalDue.subtract(const Duration(minutes: 15));
    }

    final taskNotifier = ref.read(taskListProvider.notifier);

    if (widget.taskToEdit != null) {
      final updated = widget.taskToEdit!.copyWith(
        title: finalTitle,
        description: _descController.text.trim(),
        priority: finalPriority,
        categoryId: finalCategoryId,
        dueDate: finalDue,
        clearDueDate: finalDue == null,
        reminderTime: reminder,
        clearReminderTime: reminder == null,
        recurrence: finalRecurrence,
        subtasks: _subtasks,
        focusedMinutes: finalFocusedMinutes,
      );
      taskNotifier.updateTask(updated);
    } else {
      final newTask = Task(
        id: const Uuid().v4(),
        title: finalTitle,
        description: _descController.text.trim(),
        priority: finalPriority,
        categoryId: finalCategoryId,
        dueDate: finalDue,
        reminderTime: reminder,
        recurrence: finalRecurrence,
        subtasks: _subtasks,
        focusedMinutes: finalFocusedMinutes,
        createdAt: DateTime.now(),
      );
      taskNotifier.addTask(newTask);
    }

    HapticFeedbackUtil.light();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themePalette = ref.watch(themePaletteProvider);
    final isDark = theme.brightness == Brightness.dark;
    final categories = ref.watch(categoryListProvider);
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.taskToEdit != null ? 'Edit Task' : 'New Task',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title Field
            TextField(
              controller: _titleController,
              autofocus: widget.taskToEdit == null,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Call dentist tomorrow at 2pm !urgent #Personal',
                labelText: 'Task Title (Supports Natural Language) *',
                prefixIcon: Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: themePalette.primaryColor,
                ),
              ),
            ),

            // Smart NLP Auto-Detected Attribute Chips Banner
            if (_nlpResult != null && _nlpResult!.hasAnyAttributes) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: themePalette.primaryColor
                      .withValues(alpha: isDark ? 0.16 : 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: themePalette.primaryColor
                        .withValues(alpha: isDark ? 0.38 : 0.22),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 16,
                          color: themePalette.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Smart Detected Attributes',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: themePalette.primaryColor,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: _applyNlpDetectedAttributes,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Apply & Clean',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: themePalette.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: themePalette.primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: _nlpResult!.tokens.map((token) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E243A)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.6),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                token.icon,
                                size: 12,
                                color: themePalette.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                token.displayLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
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
            const SizedBox(height: 12),

            // Description Field
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Add notes, links, or context...',
                labelText: 'Description (Optional)',
              ),
            ),
            const SizedBox(height: 16),

            // Priority Selector Chips
            Text(
              'Priority Level',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskPriority.values.map((priority) {
                final isSelected = _selectedPriority == priority;
                return FilterChip(
                  label: Text(priority.displayName),
                  selected: isSelected,
                  selectedColor: priority.containerColor,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? priority.color
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? priority.color
                        : theme.colorScheme.outlineVariant,
                  ),
                  onSelected: (val) {
                    HapticFeedbackUtil.selection();
                    setState(() => _selectedPriority = priority);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Category Selector
            Text(
              'Category / Project',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _selectedCategoryId == cat.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat.icon,
                            size: 14,
                            color: isSelected ? Colors.white : cat.color,
                          ),
                          const SizedBox(width: 6),
                          Text(cat.name),
                        ],
                      ),
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
                        setState(() => _selectedCategoryId = cat.id);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Date Pills & Custom Date Picker
            Text(
              'Schedule Due Date',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildQuickDateChip('Today', 0),
                _buildQuickDateChip('Tomorrow', 1),
                _buildQuickDateChip('Next Week', 7),
                IconButton.outlined(
                  onPressed: _pickCustomDate,
                  tooltip: 'Custom Date & Time',
                  icon: const Icon(Icons.edit_calendar_rounded, size: 20),
                ),
              ],
            ),

            if (_selectedDueDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      DateFormatUtil.formatRelative(
                        DateTime(
                          _selectedDueDate!.year,
                          _selectedDueDate!.month,
                          _selectedDueDate!.day,
                          _selectedDueTime?.hour ?? 12,
                          _selectedDueTime?.minute ?? 0,
                        ),
                      ),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDueDate = null;
                        _selectedDueTime = null;
                      });
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Reminder & Recurrence Row
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Push Reminder',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                '15m before due date',
                style: TextStyle(fontSize: 12),
              ),
              value: _enableReminder,
              onChanged: (val) {
                HapticFeedbackUtil.selection();
                setState(() => _enableReminder = val);
              },
            ),

            DropdownButtonFormField<TaskRecurrence>(
              initialValue: _selectedRecurrence,
              decoration: const InputDecoration(
                labelText: 'Repeat Schedule',
                prefixIcon: Icon(Icons.repeat_rounded),
              ),
              items: TaskRecurrence.values.map((rec) {
                return DropdownMenuItem(
                  value: rec,
                  child: Text(rec.displayName),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedRecurrence = val);
                }
              },
            ),
            const SizedBox(height: 20),

            // Subtasks Builder
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Checklist (${_subtasks.length})',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _isAddingSubtask = true),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Item'),
                ),
              ],
            ),

            if (_subtasks.isNotEmpty)
              ..._subtasks.asMap().entries.map((entry) {
                final index = entry.key;
                final subtask = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subtask.title,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        onPressed: () {
                          setState(() => _subtasks.removeAt(index));
                        },
                      ),
                    ],
                  ),
                );
              }),

            if (_isAddingSubtask)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskInputController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Subtask title...',
                        isDense: true,
                      ),
                      onSubmitted: (_) => _addSubtask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addSubtask,
                    icon: const Icon(Icons.check_rounded, size: 18),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _saveTask,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  widget.taskToEdit != null ? 'Save Changes' : 'Create Task',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateChip(String label, int offsetDays) {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day + offsetDays);
    final isSelected = _selectedDueDate != null &&
        _selectedDueDate!.year == target.year &&
        _selectedDueDate!.month == target.month &&
        _selectedDueDate!.day == target.day;

    return ActionChip(
      label: Text(label),
      backgroundColor: isSelected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      onPressed: () => _onQuickDateSelect(offsetDays),
    );
  }
}
