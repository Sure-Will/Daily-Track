# Daily Track / 每日追踪

**English** | [中文](README.zh-CN.md)

A Flutter habit tracker with calendar-based check-ins. Runs in the browser and as a native macOS desktop app.

## Status

- Records habit completion by date through a calendar-based UI, with both month and year-at-a-glance views per habit.
- Each habit card carries an inline mini-month calendar and adapts its layout to wide or narrow windows.
- Runs as a web app in Chrome and as a native macOS desktop app from one codebase.
- Multiple themes (dark 活力橙, light 浅色主题, and more) with live switching.
- Local JSON persistence, chosen per platform:
  - **macOS desktop** reads and writes the JSON data file directly.
  - **Web** syncs to a local JSON bridge, falling back to browser-local storage when the bridge is offline.
- Auto-refresh keeps the view current: external check-ins (e.g. from the Hermes bridge) show up within ~30s, the date rolls over at midnight, and a refresh never clobbers an in-progress local check-in.
- Import and export for local JSON backups.

## Supported Platforms

- macOS desktop
- Web (Chrome, or any browser via `web-server`)

## Project Structure

- `lib/main.dart` — app entry and UI
- `lib/models/habit.dart` — habit model and per-day completion logic
- `lib/services/habit_storage.dart` — bridge-first persistence with fallback
- `lib/services/habit_bridge*.dart` — platform-conditional bridge clients
  - `habit_bridge_io.dart` — native file I/O (macOS desktop)
  - `habit_bridge_web.dart` — HTTP client for the local JSON bridge (web)
  - `habit_bridge_stub.dart` — no-op fallback
- `lib/services/backup_io*.dart` — import/export helpers, selected per platform
- `bin/daily_track_bridge.dart` — localhost JSON bridge for the web app and Hermes
- `data/daily-track.example.json` — sample seed data; the app writes real data to `data/daily-track.json` (gitignored) at runtime
- `test/widget_test.dart` — widget smoke test
- `web/` — web runner and manifest
- `macos/` — macOS desktop runner

## Requirements

- Flutter SDK on the `stable` channel, Dart `^3.10.1`
- Git
- Web: Chrome
- macOS desktop: Xcode and CocoaPods

```bash
flutter doctor -v
```

## Quick Start

```bash
flutter pub get
```

### macOS desktop

```bash
flutter run -d macos
```

The desktop app reads and writes its data file directly. The path is resolved in
this order:

1. `DAILY_TRACK_DATA_PATH` environment variable
2. `~/.daily-track` pointer file — a plain text file whose only content is the
   absolute path of the data file (supports `~/` prefix)
3. The relative path `data/daily-track.json` (resolved against the working
   directory)

Apps launched from Finder or the Dock get neither shell environment variables
nor a useful working directory, so the pointer file is the reliable way to point
an installed `.app` at your data file:

```bash
echo "/path/to/your/daily-track.json" > ~/.daily-track
```

Without it, a Finder-launched app silently falls back to an internal local
cache and stops syncing with the JSON file.

### Web

Start the local JSON bridge first (optional, enables shared sync):

```bash
dart run bin/daily_track_bridge.dart
```

Then run the web app:

```bash
flutter run -d chrome
# or, if Chrome is unavailable:
flutter run -d web-server
```

The bridge listens on `http://127.0.0.1:8765` and writes `data/daily-track.json`.

Record today's fitness check-in from another local tool such as Hermes:

```bash
curl -sS -X POST http://127.0.0.1:8765/checkins \
  -H 'Content-Type: application/json' \
  -d '{"habitId":"fitness","title":"健身","date":"2026-05-28","completed":true,"source":"telegram"}'
```

## Development

```bash
flutter analyze
flutter test
flutter build web
flutter build macos
```

## Notes

- On macOS the app owns the JSON file directly; with the web bridge running, the browser and Telegram/Hermes can share the same file.
- The app polls its store about every 30s, so external writes (Hermes/Telegram) surface automatically. The poll only rebuilds the UI when the data actually changed, and it yields while a local save is in flight, so it never drops a check-in you just made.
- Without the bridge, web data is stored in the browser and survives refreshes only on the same profile and origin.
- The storage layer keeps a fallback reader for the old `daily_routine` key so existing local data still loads.
