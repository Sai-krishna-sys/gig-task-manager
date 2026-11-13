# gig_task_manager

Flutter app (Dart SDK ^3.12.2). Standard single-package layout: `lib/main.dart` entrypoint, tests in `test/`.

## Commands

- `flutter pub get` — install deps
- `flutter analyze` — static analysis (uses `analysis_options.yaml` → `flutter_lints`)
- `flutter test` — all tests
- `flutter test test/widget_test.dart` — single test file
- `flutter run` — launch app

## Notes

- `pubspec.yaml` pins `publish_to: 'none'` (private app); do not publish.
- Dart 3.12 shorthand constructor syntax is used (e.g. `colorScheme: .fromSeed(...)`); keep SDK constraint in sync.
