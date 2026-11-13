import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'router/app_router.dart';

class GigTaskApp extends StatelessWidget {
  const GigTaskApp({
    super.key,
    required this.authProvider,
    required this.taskProvider,
  });

  final AuthProvider authProvider;
  final TaskProvider taskProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
      ],
      child: MaterialApp.router(
        title: 'Gig Task Manager',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router(authProvider),
      ),
    );
  }
}
