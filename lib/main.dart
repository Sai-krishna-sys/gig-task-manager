import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'services/auth_service.dart';
import 'services/task_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  final authService = FirebaseAuthService();
  final authProvider = AuthProvider(authService);
  final taskProvider = TaskProvider(
    taskService: TaskService(),
    authService: authService,
  );

  runApp(GigTaskApp(authProvider: authProvider, taskProvider: taskProvider));
}
