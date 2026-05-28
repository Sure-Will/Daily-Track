# 每日追踪 / Daily Track

Web-first Flutter habit tracker with calendar-based check-ins.

## Current Status

- The web app is functional and can run directly in Chrome.
- Habit completion is recorded by date through a calendar-based UI.
- Changes can sync to a local JSON bridge at `data/daily-track.json`.
- If the bridge is not running, the app falls back to browser-local storage.
- Import and export are available for local JSON backups.

## Project Structure

- `lib/main.dart`: app entry and current web UI
- `lib/models/habit.dart`: habit model and per-day completion logic
- `lib/services/habit_storage.dart`: bridge-first persistence with browser fallback
- `lib/services/habit_bridge*.dart`: Flutter Web client for the local JSON bridge
- `lib/services/backup_io*.dart`: web import and export helpers
- `bin/daily_track_bridge.dart`: localhost JSON bridge for Flutter and Hermes
- `data/daily-track.json`: local source-of-truth JSON file
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

Start the local JSON bridge first:

```bash
dart run bin/daily_track_bridge.dart
```

Then start the Flutter web app:

```bash
flutter pub get
flutter run -d chrome
```

If Chrome is unavailable, start a local web server instead:

```bash
flutter run -d web-server
```

The bridge listens on `http://127.0.0.1:8765` and writes:

```text
data/daily-track.json
```

To record today's fitness check-in from another local tool such as Hermes:

```bash
curl -sS -X POST http://127.0.0.1:8765/checkins \
  -H 'Content-Type: application/json' \
  -d '{"habitId":"fitness","title":"健身","date":"2026-05-28","completed":true,"source":"telegram"}'
```

## Development Commands

```bash
flutter analyze
flutter test
flutter build web
```

## Notes

- With the bridge running, browser and Telegram/Hermes can share the same JSON file.
- Without the bridge, browser data is stored locally and survives page refreshes only on the same browser profile and origin.
- The storage layer keeps a fallback reader for the old `daily_routine` key so existing local data can still be loaded.
