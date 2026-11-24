import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/haptic_feedback_util.dart';
import '../../domain/subtask_model.dart';

/// Interactive subtasks/checklist widget with live progress bar and item adder.
class SubtaskChecklistWidget extends StatefulWidget {
  final List<Subtask> subtasks;
  final ValueChanged<String> onToggleSubtask;
  final ValueChanged<String> onAddSubtask;
  final ValueChanged<String> onDeleteSubtask;

  const SubtaskChecklistWidget({
    super.key,
    required this.subtasks,
    required this.onToggleSubtask,
    required this.onAddSubtask,
    required this.onDeleteSubtask,
  });

  @override
  State<SubtaskChecklistWidget> createState() => _SubtaskChecklistWidgetState();
}

class _SubtaskChecklistWidgetState extends State<SubtaskChecklistWidget> {
  final TextEditingController _subtaskInputController = TextEditingController();
  bool _isAdding = false;

  void _submitNewSubtask() {
    final text = _subtaskInputController.text.trim();
    if (text.isNotEmpty) {
      widget.onAddSubtask(text);
      _subtaskInputController.clear();
      setState(() => _isAdding = false);
    }
  }

  @override
  void dispose() {
    _subtaskInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.subtasks.length;
    final completed = widget.subtasks.where((s) => s.isCompleted).length;
    final progress = total > 0 ? completed / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header & Progress Summary
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.checklist_rounded, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Subtasks & Checklist',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (total > 0)
              Text(
                '$completed / $total completed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),

        if (total > 0) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? AppColors.accentEmerald : theme.colorScheme.primary,
              ),
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Subtasks List
        if (widget.subtasks.isEmpty && !_isAdding)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'No subtasks yet. Break this task into bite-sized steps.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...widget.subtasks.map((subtask) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Row(
                children: [
                  // Animated checkbox
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: Checkbox(
                      value: subtask.isCompleted,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      activeColor: theme.colorScheme.primary,
                      onChanged: (val) {
                        widget.onToggleSubtask(subtask.id);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subtask.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        decoration: subtask.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: subtask.isCompleted
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    color: theme.colorScheme.onSurfaceVariant,
                    onPressed: () {
                      HapticFeedbackUtil.light();
                      widget.onDeleteSubtask(subtask.id);
                    },
                  ),
                ],
              ),
            );
          }),

        const SizedBox(height: 8),

        // Subtask Input Row
        if (_isAdding)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subtaskInputController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter subtask description...',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onSubmitted: (_) => _submitNewSubtask(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _submitNewSubtask,
                icon: const Icon(Icons.check_rounded, size: 18),
              ),
              IconButton(
                onPressed: () => setState(() => _isAdding = false),
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ],
          )
        else
          TextButton.icon(
            onPressed: () {
              HapticFeedbackUtil.light();
              setState(() => _isAdding = true);
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Subtask'),
          ),
      ],
    );
  }
}
