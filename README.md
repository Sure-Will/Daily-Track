# 每日追踪 / Daily Track

Web-first Flutter habit tracker with calendar-based check-ins.

## Current Status

- The web app is functional and can run directly in Chrome.
- Habit completion is recorded by date through a calendar-based UI.
- Changes are saved locally in the browser.
- Import and export are available for local JSON backups.

## Project Structure

- `lib/main.dart`: app entry and current web UI
- `lib/models/habit.dart`: habit model and per-day completion logic
- `lib/services/habit_storage.dart`: browser local persistence
- `lib/services/backup_io*.dart`: web import and export helpers
- `test/widget_test.dart`: basic widget smoke test
- `web/`: web runner and manifest files

## Required Environment

- Flutter SDK on the `stable` channel with a bundled Dart SDK compatible with `^3.10.1`
- Git
- Chrome

Before running the app, verify your setup:

```bash
flutter doctor -v
```

## Quick Start

```bash
flutter pub get
flutter run -d chrome
```

If Chrome is unavailable, start a local web server instead:

```bash
flutter run -d web-server
```

## Development Commands

```bash
flutter analyze
flutter test
flutter build web
```

## Notes

- Browser data is stored locally and survives page refreshes on the same browser profile.
- The storage layer keeps a fallback reader for the old `daily_routine` key so existing local data can still be loaded.
