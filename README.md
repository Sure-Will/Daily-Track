# 每日追踪 / Daily Track

A Flutter habit tracker with calendar-based check-ins. Runs in the browser and as a native macOS desktop app.

## Current Status

- Habit completion is recorded by date through a calendar-based UI.
- Runs as a web app in Chrome and as a native macOS desktop app from the same codebase.
- Multiple theme options (dark 活力橙, light 浅色主题, and more) with live switching.
- Local JSON persistence, with the implementation chosen per platform:
  - **macOS desktop** reads and writes the JSON data file directly.
  - **Web** syncs to a local JSON bridge and falls back to browser-local storage when the bridge is not running.
- Import and export are available for local JSON backups.

## Supported Platforms

- macOS desktop
- Web (Chrome, or any browser via `web-server`)

## Project Structure

- `lib/main.dart`: app entry and UI
- `lib/models/habit.dart`: habit model and per-day completion logic
- `lib/services/habit_storage.dart`: bridge-first persistence with fallback
- `lib/services/habit_bridge*.dart`: platform-conditional bridge clients
  - `habit_bridge_io.dart`: native file I/O (macOS desktop)
  - `habit_bridge_web.dart`: HTTP client for the local JSON bridge (web)
  - `habit_bridge_stub.dart`: no-op fallback
- `lib/services/backup_io*.dart`: import and export helpers, selected per platform
- `bin/daily_track_bridge.dart`: localhost JSON bridge for the web app and Hermes
- `data/daily-track.json`: local source-of-truth JSON file
- `test/widget_test.dart`: widget smoke test
- `web/`: web runner and manifest files
- `macos/`: macOS desktop runner

## Required Environment

- Flutter SDK on the `stable` channel with a bundled Dart SDK compatible with `^3.10.1`
- Git
- For web: Chrome
- For macOS desktop: Xcode and CocoaPods

Before running the app, verify your setup:

```bash
flutter doctor -v
```

## Quick Start

Fetch dependencies first:

```bash
flutter pub get
```

### macOS desktop

```bash
flutter run -d macos
```

The desktop app reads and writes its data file directly. By default it uses the path
defined in `lib/services/habit_bridge_io.dart`; override it for your machine with the
`DAILY_TRACK_DATA_PATH` environment variable.

### Web

Start the local JSON bridge first (optional, enables shared sync):

```bash
dart run bin/daily_track_bridge.dart
```

Then start the Flutter web app:

```bash
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
flutter build macos
```

## Notes

- On macOS the app owns the JSON file directly; with the web bridge running, browser and Telegram/Hermes can share the same JSON file.
- Without the bridge, web data is stored locally and survives page refreshes only on the same browser profile and origin.
- The storage layer keeps a fallback reader for the old `daily_routine` key so existing local data can still be loaded.
