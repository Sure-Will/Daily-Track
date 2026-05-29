import 'habit_bridge_stub.dart'
    if (dart.library.io) 'habit_bridge_io.dart'
    if (dart.library.html) 'habit_bridge_web.dart'
    as habit_bridge;
import 'habit_bridge_types.dart';
import '../models/habit.dart';

Future<HabitBridgeSnapshot?> loadFromBridge() {
  return habit_bridge.loadFromBridge();
}

Future<HabitBridgeSnapshot?> saveToBridge(List<Habit> habits) {
  return habit_bridge.saveToBridge(habits);
}

void setHabitBridgeDataPathOverrideForTesting(String? path) {
  habit_bridge.setDataPathOverrideForTesting(path);
}

void setHabitBridgeDisabledForTesting(bool isDisabled) {
  habit_bridge.setDisabledForTesting(isDisabled);
}
