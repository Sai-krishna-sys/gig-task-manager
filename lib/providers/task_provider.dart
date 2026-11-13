import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';

enum TaskStatusFilter { all, pending, completed, discontinued }

class TaskProvider extends ChangeNotifier {
  TaskProvider({required this._taskService, required this._authService}) {
    _authSubscription = _authService.authStateChanges().listen((user) {
      _uid = user?.uid;
      _tasks = [];
      _error = null;
      _isLoading = _uid != null;
      _taskSubscription?.cancel();
      if (_uid != null) {
        _taskSubscription = _taskService.tasksStream().listen(
          (tasks) {
            _tasks = tasks..sort((a, b) => a.dueDate.compareTo(b.dueDate));
            _isLoading = false;
            _error = null;
            notifyListeners();
          },
          onError: (Object e) {
            _error = 'Failed to load tasks.';
            _isLoading = false;
            notifyListeners();
          },
        );
      } else {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  final TaskService _taskService;
  final AuthService _authService;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<TaskModel>>? _taskSubscription;

  String? _uid;
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  bool _isSaving = false;
  final Set<String> _statusUpdating = {};
  String? _error;
  TaskPriority? _priorityFilter;
  TaskStatusFilter _statusFilter = TaskStatusFilter.all;

  List<TaskModel> get tasks {
    var result = List<TaskModel>.from(_tasks);
    if (_priorityFilter != null) {
      result = result.where((t) => t.priority == _priorityFilter).toList();
    }
    switch (_statusFilter) {
      case TaskStatusFilter.pending:
        result = result.where((t) => t.status == TaskStatus.pending).toList();
      case TaskStatusFilter.completed:
        result = result.where((t) => t.status == TaskStatus.completed).toList();
      case TaskStatusFilter.discontinued:
        result = result
            .where((t) => t.status == TaskStatus.discontinued)
            .toList();
      case TaskStatusFilter.all:
        break;
    }
    result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return result;
  }

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool isStatusUpdating(String taskId) => _statusUpdating.contains(taskId);
  String? get error => _error;
  TaskPriority? get priorityFilter => _priorityFilter;
  TaskStatusFilter get statusFilter => _statusFilter;

  int get totalCount => _tasks.length;
  int get pendingCount =>
      _tasks.where((t) => t.status == TaskStatus.pending).length;
  int get completedCount =>
      _tasks.where((t) => t.status == TaskStatus.completed).length;
  int get discontinuedCount =>
      _tasks.where((t) => t.status == TaskStatus.discontinued).length;

  void setPriorityFilter(TaskPriority? value) {
    _priorityFilter = value;
    notifyListeners();
  }

  void setStatusFilter(TaskStatusFilter value) {
    _statusFilter = value;
    notifyListeners();
  }

  void resetFilters() {
    _priorityFilter = null;
    _statusFilter = TaskStatusFilter.all;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> addTask(TaskModel task) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await _taskService.addTask(task).timeout(const Duration(seconds: 10));
      return true;
    } on TimeoutException {
      _error = 'Request timed out. Check Firestore API/network.';
      notifyListeners();
      return false;
    } catch (e, st) {
      if (e is FirebaseException) {
        _error = 'Failed to add task (${e.code}): ${e.message}';
        debugPrint(
          'addTask FirebaseException code=${e.code} message=${e.message}',
        );
      } else {
        _error = 'Failed to add task: $e';
      }
      debugPrint('addTask error: $e');
      debugPrintStack(stackTrace: st);
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await _taskService.updateTask(task).timeout(const Duration(seconds: 10));
      return true;
    } on TimeoutException {
      _error = 'Request timed out. Check Firestore API/network.';
      notifyListeners();
      return false;
    } catch (e, st) {
      if (e is FirebaseException) {
        _error = 'Failed to update task (${e.code}): ${e.message}';
        debugPrint(
          'updateTask FirebaseException code=${e.code} message=${e.message}',
        );
      } else {
        _error = 'Failed to update task: $e';
      }
      debugPrint('updateTask error: $e');
      debugPrintStack(stackTrace: st);
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTask(String taskId) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await _taskService
          .deleteTask(taskId)
          .timeout(const Duration(seconds: 10));
      return true;
    } on TimeoutException {
      _error = 'Request timed out. Check Firestore API/network.';
      notifyListeners();
      return false;
    } catch (e, st) {
      if (e is FirebaseException) {
        _error = 'Failed to delete task (${e.code}): ${e.message}';
        debugPrint(
          'deleteTask FirebaseException code=${e.code} message=${e.message}',
        );
      } else {
        _error = 'Failed to delete task: $e';
      }
      debugPrint('deleteTask error: $e');
      debugPrintStack(stackTrace: st);
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> toggleComplete(String taskId, bool value) async {
    try {
      await _taskService
          .toggleComplete(taskId, value)
          .timeout(const Duration(seconds: 10));
      return true;
    } on TimeoutException {
      _error = 'Request timed out. Check Firestore API/network.';
      notifyListeners();
      return false;
    } catch (e, st) {
      if (e is FirebaseException) {
        _error = 'Failed to update task (${e.code}): ${e.message}';
      } else {
        _error = 'Failed to update task: $e';
      }
      debugPrint('toggleComplete error: $e');
      debugPrintStack(stackTrace: st);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus(TaskModel task, TaskStatus status) async {
    if (task.status == status) return true;
    _statusUpdating.add(task.id);
    _error = null;
    notifyListeners();
    try {
      await _taskService
          .updateStatus(task.id, status)
          .timeout(const Duration(seconds: 10));
      return true;
    } on TimeoutException {
      _error = 'Request timed out. Check Firestore API/network.';
      notifyListeners();
      return false;
    } catch (e, st) {
      if (e is FirebaseException) {
        _error = 'Failed to update status (${e.code}): ${e.message}';
      } else {
        _error = 'Failed to update status: $e';
      }
      debugPrint('updateStatus error: $e');
      debugPrintStack(stackTrace: st);
      notifyListeners();
      return false;
    } finally {
      _statusUpdating.remove(task.id);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _taskSubscription?.cancel();
    super.dispose();
  }
}
