# 每日追踪 / Daily Track

[English](README.md) | **中文**

基于日历打卡的 Flutter 习惯追踪应用，可在浏览器中运行，也可作为原生 macOS 桌面应用运行。

## 现状

- 通过日历界面按日期记录习惯完成情况。
- 同一套代码既能在 Chrome 中以 Web 应用运行，也能作为原生 macOS 桌面应用运行。
- 多种主题（深色「活力橙」、浅色「浅色主题」等），支持实时切换。
- 本地 JSON 持久化，按平台选择实现：
  - **macOS 桌面**：直接读写 JSON 数据文件。
  - **Web**：同步到本地 JSON bridge；bridge 未运行时回退到浏览器本地存储。
- 支持导入/导出本地 JSON 备份。

## 支持平台

- macOS 桌面
- Web（Chrome，或通过 `web-server` 在任意浏览器中运行）

## 项目结构

- `lib/main.dart`：应用入口与界面
- `lib/models/habit.dart`：习惯模型与按日完成逻辑
- `lib/services/habit_storage.dart`：bridge 优先、带回退的持久化层
- `lib/services/habit_bridge*.dart`：按平台条件编译的 bridge 客户端
  - `habit_bridge_io.dart`：原生文件读写（macOS 桌面）
  - `habit_bridge_web.dart`：本地 JSON bridge 的 HTTP 客户端（Web）
  - `habit_bridge_stub.dart`：空实现回退
- `lib/services/backup_io*.dart`：按平台选择的导入/导出工具
- `bin/daily_track_bridge.dart`：供 Web 应用与 Hermes 使用的 localhost JSON bridge
- `data/daily-track.example.json`：示例种子数据；应用运行时把真实数据写入 `data/daily-track.json`（已 gitignore）
- `test/widget_test.dart`：界面冒烟测试
- `web/`：Web 运行器与 manifest
- `macos/`：macOS 桌面运行器

## 环境要求

- `stable` 通道的 Flutter SDK，Dart `^3.10.1`
- Git
- Web：Chrome
- macOS 桌面：Xcode 与 CocoaPods

```bash
flutter doctor -v
```

## 快速开始

```bash
flutter pub get
```

### macOS 桌面

```bash
flutter run -d macos
```

桌面应用会直接读写其数据文件。默认使用相对路径 `data/daily-track.json`，
可通过环境变量 `DAILY_TRACK_DATA_PATH` 覆盖。

### Web

先启动本地 JSON bridge（可选，用于共享同步）：

```bash
dart run bin/daily_track_bridge.dart
```

再启动 Web 应用：

```bash
flutter run -d chrome
# Chrome 不可用时：
flutter run -d web-server
```

bridge 监听 `http://127.0.0.1:8765`，写入 `data/daily-track.json`。

从 Hermes 等其他本地工具记录今天的健身打卡：

```bash
curl -sS -X POST http://127.0.0.1:8765/checkins \
  -H 'Content-Type: application/json' \
  -d '{"habitId":"fitness","title":"健身","date":"2026-05-28","completed":true,"source":"telegram"}'
```

## 开发命令

```bash
flutter analyze
flutter test
flutter build web
flutter build macos
```

## 说明

- 在 macOS 上应用直接拥有该 JSON 文件；运行 Web bridge 时，浏览器与 Telegram/Hermes 可共享同一文件。
- 不运行 bridge 时，Web 数据存储在浏览器中，仅在同一浏览器 profile 与同源下刷新后仍保留。
- 存储层保留了对旧 `daily_routine` 键的回退读取，因此既有本地数据仍可加载。
