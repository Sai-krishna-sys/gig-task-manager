import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gig_task_manager/models/task_model.dart';
import 'package:gig_task_manager/providers/task_provider.dart';
import 'package:gig_task_manager/services/auth_service.dart';
import 'package:gig_task_manager/services/task_service.dart';

class _FakeUser implements User {
  @override
  String get uid => 'test-user';

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeAuthService implements AuthService {
  final _controller = StreamController<User?>.broadcast();

  @override
  Stream<User?> authStateChanges() => _controller.stream;

  @override
  User? get currentUser => _FakeUser();

  @override
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<void> logout() async {}

  void signIn() => _controller.add(_FakeUser());

  void signOut() => _controller.add(null);
}

class _FakeTaskService extends TaskService {
  _FakeTaskService() : super();

  final _controller = StreamController<List<TaskModel>>.broadcast();
  final List<TaskModel> _tasks = [];

  @override
  Stream<List<TaskModel>> tasksStream() => _controller.stream;

  @override
  Future<void> addTask(TaskModel task) async {
    _tasks.add(task.copyWith(id: 'new-${_tasks.length}'));
    _controller.add(List<TaskModel>.from(_tasks));
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
      _controller.add(List<TaskModel>.from(_tasks));
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    _controller.add(List<TaskModel>.from(_tasks));
  }

  @override
  Future<void> toggleComplete(String taskId, bool value) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      _tasks[index] = _tasks[index].copyWith(
        status: value ? TaskStatus.completed : TaskStatus.pending,
      );
      _controller.add(List<TaskModel>.from(_tasks));
    }
  }

  @override
  Future<void> updateStatus(String taskId, TaskStatus status) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      _tasks[index] = _tasks[index].copyWith(status: status);
      _controller.add(List<TaskModel>.from(_tasks));
    }
  }
}

void main() {
  test('TaskProvider filters and sorts tasks', () async {
    final auth = _FakeAuthService();
    final service = _FakeTaskService();
    final provider = TaskProvider(taskService: service, authService: auth);

    auth.signIn();
    await Future<void>.delayed(Duration.zero);

    final now = DateTime.now();
    await service.addTask(
      TaskModel(
        id: '',
        title: 'B',
        description: '',
        dueDate: now.add(const Duration(days: 2)),
        priority: TaskPriority.low,
        status: TaskStatus.pending,
      ),
    );
    await service.addTask(
      TaskModel(
        id: '',
        title: 'A',
        description: '',
        dueDate: now.add(const Duration(days: 1)),
        priority: TaskPriority.high,
        status: TaskStatus.completed,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    provider.setPriorityFilter(TaskPriority.high);
    provider.setStatusFilter(TaskStatusFilter.completed);
    expect(provider.tasks.length, 1);
    expect(provider.tasks.first.title, 'A');

    provider.resetFilters();
    expect(provider.tasks.length, 2);
    expect(provider.tasks.first.title, 'A');
  });
}
