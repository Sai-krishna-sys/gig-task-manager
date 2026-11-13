import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_model.dart';

class TaskService {
  TaskService({this._firestore, this._auth});

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  FirebaseFirestore get _firestoreInstance =>
      _firestore ?? FirebaseFirestore.instance;
  FirebaseAuth get _authInstance => _auth ?? FirebaseAuth.instance;

  String get _uid {
    final uid = _authInstance.currentUser?.uid;
    if (uid == null) throw StateError('No authenticated user.');
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _tasksRef =>
      _firestoreInstance.collection('users').doc(_uid).collection('tasks');

  Stream<List<TaskModel>> tasksStream() {
    return _tasksRef
        .orderBy('dueDate')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList(),
        );
  }

  Future<void> addTask(TaskModel task) {
    return _tasksRef.add({
      ...task.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTask(TaskModel task) {
    return _tasksRef.doc(task.id).update({
      ...task.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTask(String taskId) {
    return _tasksRef.doc(taskId).delete();
  }

  Future<void> toggleComplete(String taskId, bool value) {
    return _tasksRef.doc(taskId).update({
      'status': value ? TaskStatus.completed.name : TaskStatus.pending.name,
      'isCompleted': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus(String taskId, TaskStatus status) {
    return _tasksRef.doc(taskId).update({
      'status': status.name,
      'isCompleted': status == TaskStatus.completed,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
