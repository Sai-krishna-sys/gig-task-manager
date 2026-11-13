# Gig Task Manager

Flutter task management app for gig workers using Firebase Authentication and Cloud Firestore.

## Features

- Email/password registration, login and logout
- User-specific task CRUD
- Task status: Pending, Completed, Discontinued
- Priority levels: Low, Medium, High
- Filters by status and priority
- Due-date ascending sorting
- Firestore real-time updates
- Offline persistence
- Material 3 responsive UI

## Architecture

```text
lib/
  core/        theme, validators
  models/      TaskModel
  services/    AuthService, TaskService
  providers/   AuthProvider, TaskProvider
  screens/     auth, dashboard, tasks
  widgets/     reusable UI components
  router/      GoRouter configuration
```

State management uses Provider. Firebase access is isolated in services.

## Setup

1. Install Flutter and dependencies:

```bash
flutter pub get
```

2. Configure Firebase:

- Create a Firebase project.
- Enable Email/Password authentication.
- Create a Cloud Firestore database.
- Deploy `firestore.rules`.
- Ensure `lib/firebase_options.dart` matches your Firebase app.

3. Run:

```bash
flutter run
```

## Tests

```bash
flutter analyze
flutter test
```

## Security

Firestore rules restrict all user and task documents to the authenticated owner.
