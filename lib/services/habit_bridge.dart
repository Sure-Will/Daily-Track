import 'habit_bridge_stub.dart'
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
