import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';

class HabitStorage {
  HabitStorage();

  static const _storageKey = 'daily_routine_habits_v1';

  Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

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

      return habits;
    } catch (_) {
      final defaults = _defaultHabits();
      await saveHabits(defaults);
      return defaults;
    }
  }

  Future<void> saveHabits(List<Habit> habits) async {
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
    return const <Habit>[
      Habit(id: 'wake-up', title: '早起 6:30'),
      Habit(id: 'reading', title: '阅读 30 分钟'),
      Habit(id: 'exercise', title: '运动 20 分钟'),
      Habit(id: 'no-shorts', title: '不刷短视频'),
    ];
  }
}
