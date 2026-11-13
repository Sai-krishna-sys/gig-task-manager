import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import 'priority_badge.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.isStatusUpdating,
    required this.onToggle,
    required this.onStatusChanged,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  final TaskModel task;
  final bool isStatusUpdating;
  final ValueChanged<bool> onToggle;
  final ValueChanged<TaskStatus> onStatusChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  String _statusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.discontinued:
        return 'Stopped';
    }
  }

  Color _statusColor(TaskStatus status, BuildContext context) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.discontinued:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final due = DateFormat.yMMMd().format(task.dueDate);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.status == TaskStatus.completed,
                onChanged: task.status == TaskStatus.discontinued
                    ? null
                    : (v) => onToggle(v ?? false),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: task.status == TaskStatus.discontinued
                            ? Colors.grey.shade600
                            : null,
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        PriorityBadge(priority: task.priority),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.event,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(due, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (isStatusUpdating)
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      PopupMenuButton<TaskStatus>(
                        initialValue: task.status,
                        onSelected: onStatusChanged,
                        itemBuilder: (context) => TaskStatus.values
                            .map(
                              (s) => PopupMenuItem<TaskStatus>(
                                value: s,
                                child: Text(_statusLabel(s)),
                              ),
                            )
                            .toList(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _statusLabel(task.status),
                              style: TextStyle(
                                color: _statusColor(task.status, context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
