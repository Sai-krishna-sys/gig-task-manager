import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { pending, completed, discontinued }

enum TaskPriority { low, medium, high }

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isCompleted => status == TaskStatus.completed;

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority.name,
      'status': status.name,
      'isCompleted': status == TaskStatus.completed,
    };
  }

  factory TaskModel.fromMap(String id, Map<String, dynamic> data) {
    final statusValue = data['status'] as String?;
    final isCompleted = (data['isCompleted'] as bool?) ?? false;
    final resolvedStatus = statusValue == null
        ? (isCompleted ? TaskStatus.completed : TaskStatus.pending)
        : TaskStatus.values.firstWhere(
            (s) => s.name == statusValue,
            orElse: () =>
                isCompleted ? TaskStatus.completed : TaskStatus.pending,
          );
    return TaskModel(
      id: id,
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: resolvedStatus,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory TaskModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    return TaskModel.fromMap(doc.id, doc.data() ?? <String, dynamic>{});
  }
}
