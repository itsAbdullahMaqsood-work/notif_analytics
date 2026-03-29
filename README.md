# notif_analytics

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Flavors

This project supports three environments:

- `development`
- `staging`
- `production`

### Run

```bash
flutter run --flavor development -t lib/main_development.dart
flutter run --flavor staging -t lib/main_staging.dart
flutter run --flavor production -t lib/main_production.dart
```

### Build

```bash
flutter build apk --flavor development -t lib/main_development.dart
flutter build apk --flavor staging -t lib/main_staging.dart
flutter build apk --flavor production -t lib/main_production.dart
```
