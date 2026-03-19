# 每日追踪 / Daily Track

Flutter multi-platform habit tracker prototype.

## Current Status

- The app is still in an early prototype stage.
- The home screen UI is implemented, but the habit list is mocked in code.
- The "Add habit" button is present but not wired up yet.
- There is no persistence, sync, routing, or state management layer yet.

## Project Structure

- `lib/main.dart`: current app entry and prototype UI
- `test/widget_test.dart`: basic widget smoke test
- `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/`: Flutter platform runners

## Required Environment

This repository is a Flutter app created from the `stable` channel. The project
metadata records Flutter revision `19074d12f7eaf6a8180cd4036a430c1d76de904e`,
and `pubspec.yaml` requires Dart SDK `^3.10.1`.

Minimum development environment:

- Flutter SDK on the `stable` channel with a bundled Dart SDK compatible with `^3.10.1`
- Git
- An editor with Flutter and Dart support, such as VSCode or Android Studio

Choose at least one target environment:

- Web: Chrome or Microsoft Edge
- macOS desktop: Xcode
- iOS: Xcode, CocoaPods, and an iOS Simulator or device
- Android: Android Studio, Android SDK, and accepted Android licenses

Before running the app, verify your setup:

```bash
flutter doctor -v
```

## Quick Start

1. Install Flutter and add it to your `PATH`.
2. Clone the repository.
3. Fetch dependencies:

```bash
flutter pub get
```

4. Run on the easiest target first:

```bash
flutter run -d chrome
```

If Chrome isn't installed yet, start a local web server instead:

```bash
flutter run -d web-server
```

Other common targets:

```bash
flutter run -d macos
flutter run -d ios
flutter run -d android
```

If you are unsure which targets are available on your machine:

```bash
flutter devices
```

## Development Commands

Static analysis:

```bash
flutter analyze
```

Widget tests:

```bash
flutter test
```

## Notes

- `lib/main.dart` currently uses mock habit data for the home screen.
- The first useful milestone is usually to replace the mock list with a real `Habit` model and local persistence.
