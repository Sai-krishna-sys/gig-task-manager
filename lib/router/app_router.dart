import 'package:go_router/go_router.dart';

import '../models/task_model.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/tasks/add_edit_task_screen.dart';
import '../screens/tasks/task_detail_screen.dart';

class AppRouter {
  static GoRouter router(AuthProvider auth) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: auth,
      redirect: (context, state) {
        final location = state.matchedLocation;
        final isAuthRoute = location == '/login' ||
            location == '/register' ||
            location == '/onboarding' ||
            location == '/splash';

        if (!auth.isInitialized) return null;

        if (!auth.isAuthenticated && !isAuthRoute) {
          return '/onboarding';
        }
        if (auth.isAuthenticated &&
            (location == '/login' ||
                location == '/register' ||
                location == '/onboarding' ||
                location == '/splash')) {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/tasks/new',
          builder: (context, state) => const AddEditTaskScreen(),
        ),
        GoRoute(
          path: '/tasks/edit',
          builder: (context, state) =>
              AddEditTaskScreen(task: state.extra as TaskModel?),
        ),
        GoRoute(
          path: '/tasks/detail',
          builder: (context, state) =>
              TaskDetailScreen(task: state.extra as TaskModel),
        ),
      ],
    );
  }
}

