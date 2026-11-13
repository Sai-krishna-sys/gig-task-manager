import 'package:flutter_test/flutter_test.dart';
import 'package:gig_task_manager/models/task_model.dart';

void main() {
  test('TaskModel serializes and deserializes status', () {
    final task = TaskModel(
      id: '1',
      title: 'Test',
      description: 'Desc',
      dueDate: DateTime(2026, 1, 1),
      priority: TaskPriority.high,
      status: TaskStatus.discontinued,
    );
    final map = task.toMap();
    final restored = TaskModel.fromMap('1', map);
    expect(restored.status, TaskStatus.discontinued);
    expect(restored.title, 'Test');
  });

  test('Backward compatibility: isCompleted true maps to completed', () {
    final restored = TaskModel.fromMap('2', {
      'title': 'Old',
      'dueDate': null,
      'isCompleted': true,
    });
    expect(restored.status, TaskStatus.completed);
  });

  test('Backward compatibility: isCompleted false maps to pending', () {
    final restored = TaskModel.fromMap('3', {
      'title': 'Old',
      'dueDate': null,
      'isCompleted': false,
    });
    expect(restored.status, TaskStatus.pending);
  });
}
