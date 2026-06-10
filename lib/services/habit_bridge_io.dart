import 'dart:convert';
import 'dart:io';

import 'habit_bridge_types.dart';
import '../models/habit.dart';

const defaultDataPath = 'data/daily-track.json';
const dataPathEnvKey = 'DAILY_TRACK_DATA_PATH';
const pointerFileName = '.daily-track';

String? _dataPathOverride;
bool _isDisabledForTesting = false;

Future<HabitBridgeSnapshot?> loadFromBridge() async {
  if (_isDisabledForTesting) {
    return null;
  }

  try {
    final dataFile = _dataFile();
    await _ensureDataFile(dataFile);

    final decoded = jsonDecode(await dataFile.readAsString());
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return HabitBridgeSnapshot.fromJson({
      ...decoded,
      'filePath': dataFile.path,
    });
  } catch (_) {
    return null;
  }
}

Future<HabitBridgeSnapshot?> saveToBridge(List<Habit> habits) async {
  if (_isDisabledForTesting) {
    return null;
  }

  try {
    final dataFile = _dataFile();
    final snapshot = HabitBridgeSnapshot(
      habits: habits,
      filePath: dataFile.path,
      savedAt: DateTime.now(),
    );
    await _writePayload(dataFile, snapshot.toJson());
    return snapshot;
  } catch (_) {
    return null;
  }
}

File _dataFile() {
  if (_dataPathOverride != null && _dataPathOverride!.trim().isNotEmpty) {
    return File(_dataPathOverride!.trim()).absolute;
  }

  return File(
    resolveDataPath(
      environment: Platform.environment,
      pointerContent: _readPointerFile(),
    ),
  ).absolute;
}

/// Pure precedence logic (env var > pointer file > cwd-relative default),
/// kept free of Platform/file-system access so it can be unit-tested.
///
/// The pointer file exists because GUI launches (Finder/Dock) get neither
/// shell env vars nor a meaningful cwd, so a file in the home directory is
/// the only config channel that reaches them.
String resolveDataPath({
  required Map<String, String> environment,
  String? pointerContent,
}) {
  final configuredPath = environment[dataPathEnvKey]?.trim();
  if (configuredPath != null && configuredPath.isNotEmpty) {
    return expandHomePath(configuredPath, environment);
  }

  final pointedPath = pointerContent?.trim();
  if (pointedPath != null && pointedPath.isNotEmpty) {
    return expandHomePath(pointedPath, environment);
  }

  return defaultDataPath;
}

String expandHomePath(String path, Map<String, String> environment) {
  if (!path.startsWith('~/')) {
    return path;
  }

  final home = (environment['HOME'] ?? environment['USERPROFILE'])?.trim();
  if (home == null || home.isEmpty) {
    return path;
  }

  return '$home${path.substring(1)}';
}

String? _readPointerFile() {
  final home =
      (Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'])
          ?.trim();
  if (home == null || home.isEmpty) {
    return null;
  }

  try {
    final pointerFile = File('$home/$pointerFileName');
    if (!pointerFile.existsSync()) {
      return null;
    }

    return pointerFile.readAsStringSync();
  } catch (_) {
    return null;
  }
}

Future<void> _ensureDataFile(File dataFile) async {
  if (await dataFile.exists()) {
    return;
  }

  await _writePayload(
    dataFile,
    HabitBridgeSnapshot(
      habits: const <Habit>[Habit(id: 'fitness', title: '健身')],
      filePath: dataFile.path,
      savedAt: DateTime.now(),
    ).toJson(),
  );
}

Future<void> _writePayload(File dataFile, Map<String, dynamic> payload) async {
  await dataFile.parent.create(recursive: true);
  final tempFile = File('${dataFile.path}.tmp');
  await tempFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(payload),
  );

  if (await dataFile.exists()) {
    await dataFile.delete();
  }
  await tempFile.rename(dataFile.path);
}

void setDataPathOverrideForTesting(String? path) {
  _dataPathOverride = path;
}

void setDisabledForTesting(bool isDisabled) {
  _isDisabledForTesting = isDisabled;
}
