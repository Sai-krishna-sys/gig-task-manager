import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/task_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(TaskModel task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final ok = await context.read<TaskProvider>().deleteTask(task.id);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task deleted.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<TaskModel> _visibleTasks(TaskProvider tasks) {
    final query = _searchController.text.trim().toLowerCase();
    return tasks.tasks.where((task) {
      if (query.isEmpty) return true;
      return task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query);
    }).toList();
  }

  Map<String, List<TaskModel>> _groupTasks(List<TaskModel> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final groups = <String, List<TaskModel>>{
      'Overdue': [],
      'Today': [],
      'Tomorrow': [],
      'This week': [],
      'Later': [],
    };
    for (final task in tasks) {
      final due = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      if (due.isBefore(today)) {
        groups['Overdue']!.add(task);
      } else if (due == today) {
        groups['Today']!.add(task);
      } else if (due == tomorrow) {
        groups['Tomorrow']!.add(task);
      } else if (due.isAfter(tomorrow) &&
          due.isBefore(today.add(const Duration(days: 8)))) {
        groups['This week']!.add(task);
      } else {
        groups['Later']!.add(task);
      }
    }
    groups.removeWhere((key, value) => value.isEmpty);
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tasks = context.watch<TaskProvider>();
    final name = auth.user?.displayName ?? 'there';
    final visible = _visibleTasks(tasks);
    final grouped = _groupTasks(visible);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, $name', style: const TextStyle(fontSize: 16)),
            const Text('My tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search tasks',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatCard(label: 'Total', value: tasks.totalCount, icon: Icons.list_alt, color: Theme.of(context).colorScheme.primary),
                    _StatCard(label: 'Pending', value: tasks.pendingCount, icon: Icons.schedule, color: Colors.blue),
                    _StatCard(label: 'Done', value: tasks.completedCount, icon: Icons.task_alt, color: Colors.green),
                    _StatCard(label: 'Stopped', value: tasks.discontinuedCount, icon: Icons.stop_circle_outlined, color: Colors.red),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      PopupMenuButton<TaskPriority?>(
                        initialValue: tasks.priorityFilter,
                        onSelected: tasks.setPriorityFilter,
                        itemBuilder: (context) => [
                          const PopupMenuItem<TaskPriority?>(value: null, child: Text('All priorities')),
                          ...TaskPriority.values.map(
                            (p) => PopupMenuItem<TaskPriority?>(
                              value: p,
                              child: Text(p.name[0].toUpperCase() + p.name.substring(1)),
                            ),
                          ),
                        ],
                        child: _FilterChip(label: tasks.priorityFilter == null ? 'All priorities' : tasks.priorityFilter!.name[0].toUpperCase() + tasks.priorityFilter!.name.substring(1)),
                      ),
                      const SizedBox(width: 8),
                      ...TaskPriority.values.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(p.name[0].toUpperCase() + p.name.substring(1)),
                            selected: tasks.priorityFilter == p,
                            onSelected: (_) => tasks.setPriorityFilter(p),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      PopupMenuButton<TaskStatusFilter>(
                        initialValue: tasks.statusFilter,
                        onSelected: tasks.setStatusFilter,
                        itemBuilder: (context) => TaskStatusFilter.values
                            .map((s) => PopupMenuItem<TaskStatusFilter>(value: s, child: Text(_statusLabel(s))))
                            .toList(),
                        child: _FilterChip(label: _statusLabel(tasks.statusFilter)),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Pending'),
                        selected: tasks.statusFilter == TaskStatusFilter.pending,
                        onSelected: (_) => tasks.setStatusFilter(TaskStatusFilter.pending),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Completed'),
                        selected: tasks.statusFilter == TaskStatusFilter.completed,
                        onSelected: (_) => tasks.setStatusFilter(TaskStatusFilter.completed),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Stopped'),
                        selected: tasks.statusFilter == TaskStatusFilter.discontinued,
                        onSelected: (_) => tasks.setStatusFilter(TaskStatusFilter.discontinued),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isLoading
                ? const Center(child: CircularProgressIndicator())
                : visible.isEmpty
                    ? EmptyState(
                        message: tasks.totalCount == 0
                            ? 'No tasks yet. Add your first task.'
                            : 'No tasks match the selected filters.',
                      )
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 96),
                        children: grouped.entries.expand((entry) {
                          return [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                              child: Text(
                                entry.key,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: entry.key == 'Overdue' ? Colors.red : null,
                                    ),
                              ),
                            ),
                            ...entry.value.map(
                              (task) => TaskCard(
                                task: task,
                                isStatusUpdating: tasks.isStatusUpdating(task.id),
                                onToggle: (value) async {
                                  final ok = await tasks.toggleComplete(task.id, value);
                                  if (!ok && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(tasks.error ?? 'Update failed.')),
                                    );
                                  }
                                },
                                onStatusChanged: (status) async {
                                  final ok = await tasks.updateStatus(task, status);
                                  if (!ok && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(tasks.error ?? 'Update failed.'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                onTap: () => context.push('/tasks/detail', extra: task),
                                onEdit: () => context.push('/tasks/edit', extra: task),
                                onDelete: () => _confirmDelete(task),
                              ),
                            ),
                          ];
                        }).toList(),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/new'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) context.go('/profile');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.task_alt_outlined), selectedIcon: Icon(Icons.task_alt), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  String _statusLabel(TaskStatusFilter filter) {
    switch (filter) {
      case TaskStatusFilter.all:
        return 'All statuses';
      case TaskStatusFilter.pending:
        return 'Pending';
      case TaskStatusFilter.completed:
        return 'Completed';
      case TaskStatusFilter.discontinued:
        return 'Stopped';
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600)),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(height: 8),
              Text('$value', style: Theme.of(context).textTheme.titleLarge),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
