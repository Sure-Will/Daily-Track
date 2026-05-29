import 'dart:convert';
import 'dart:io';

import 'habit_bridge_types.dart';
import '../models/habit.dart';

const _defaultDataPath = '/Users/sure/repos/Daily-Track/data/daily-track.json';
const _dataPathEnvKey = 'DAILY_TRACK_DATA_PATH';

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

  final configuredPath = Platform.environment[_dataPathEnvKey];
  final path = configuredPath == null || configuredPath.trim().isEmpty
      ? _defaultDataPath
      : configuredPath.trim();
  return File(path).absolute;
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
