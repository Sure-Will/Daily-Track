import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'habit_bridge.dart';
import '../models/habit.dart';

class HabitStorage {
  HabitStorage();

  static const _storageKey = 'daily_track_habits_v1';
  static const _legacyStorageKey = 'daily_routine_habits_v1';

  bool _bridgeConnected = false;
  String? _bridgeFilePath;
  DateTime? _bridgeSavedAt;

  bool get bridgeConnected => _bridgeConnected;
  String? get bridgeFilePath => _bridgeFilePath;
  DateTime? get bridgeSavedAt => _bridgeSavedAt;

  Future<List<Habit>> loadHabits() async {
    final bridgeSnapshot = await loadFromBridge();
    if (bridgeSnapshot != null) {
      _bridgeConnected = true;
      _bridgeFilePath = bridgeSnapshot.filePath;
      _bridgeSavedAt = bridgeSnapshot.savedAt;
      final habits = bridgeSnapshot.habits.isEmpty
          ? _defaultHabits()
          : bridgeSnapshot.habits;
      await _saveBrowserCache(habits);
      return habits;
    }

    _bridgeConnected = false;
    _bridgeFilePath = null;
    _bridgeSavedAt = null;

    final prefs = await SharedPreferences.getInstance();
    final raw =
        prefs.getString(_storageKey) ?? prefs.getString(_legacyStorageKey);

    if (raw == null || raw.isEmpty) {
      final defaults = _defaultHabits();
      await saveHabits(defaults);
      return defaults;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final items = decoded['habits'] as List<dynamic>? ?? <dynamic>[];
      final habits = items
          .whereType<Map<String, dynamic>>()
          .map(Habit.fromJson)
          .toList();

      if (habits.isEmpty) {
        final defaults = _defaultHabits();
        await saveHabits(defaults);
        return defaults;
      }

      if (_isUntouchedOldDefaultSet(habits)) {
        final defaults = _defaultHabits();
        await saveHabits(defaults);
        return defaults;
      }

      return habits;
    } catch (_) {
      final defaults = _defaultHabits();
      await saveHabits(defaults);
      return defaults;
    }
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final bridgeSnapshot = await saveToBridge(habits);
    if (bridgeSnapshot != null) {
      _bridgeConnected = true;
      _bridgeFilePath = bridgeSnapshot.filePath;
      _bridgeSavedAt = bridgeSnapshot.savedAt;
    } else {
      _bridgeConnected = false;
      _bridgeFilePath = null;
      _bridgeSavedAt = null;
    }

    await _saveBrowserCache(habits);
  }

  Future<void> _saveBrowserCache(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'version': 2,
      'savedAt': DateTime.now().toIso8601String(),
      'habits': habits.map((habit) => habit.toJson()).toList(),
    };

    await prefs.setString(_storageKey, jsonEncode(payload));
  }

  String buildExportPayload(List<Habit> habits) {
    return const JsonEncoder.withIndent('  ').convert({
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'habits': habits.map((habit) => habit.toJson()).toList(),
    });
  }

  List<Habit> parseImportPayload(String payload) {
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('备份文件格式不正确');
    }

    final items = decoded['habits'];
    if (items is! List<dynamic>) {
      throw const FormatException('备份文件里没有 habits 列表');
    }

    final habits = items
        .whereType<Map<String, dynamic>>()
        .map(Habit.fromJson)
        .toList();

    if (habits.isEmpty) {
      throw const FormatException('导入文件里没有可用习惯');
    }

    return habits;
  }

  List<Habit> _defaultHabits() {
    return const <Habit>[Habit(id: 'fitness', title: '健身')];
  }

  bool _isUntouchedOldDefaultSet(List<Habit> habits) {
    const oldDefaultIds = <String>{
      'wake-up',
      'reading',
      'exercise',
      'no-shorts',
    };

    if (habits.length != oldDefaultIds.length) {
      return false;
    }

    return habits.every(
      (habit) =>
          oldDefaultIds.contains(habit.id) && habit.completedDates.isEmpty,
    );
  }
}
