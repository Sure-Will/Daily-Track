import '../models/habit.dart';

class HabitBridgeSnapshot {
  const HabitBridgeSnapshot({
    required this.habits,
    this.filePath,
    this.savedAt,
  });

  final List<Habit> habits;
  final String? filePath;
  final DateTime? savedAt;

  factory HabitBridgeSnapshot.fromJson(Map<String, dynamic> json) {
    final items = json['habits'] as List<dynamic>? ?? <dynamic>[];
    final savedAtRaw = json['savedAt'] as String?;

    return HabitBridgeSnapshot(
      habits: items
          .whereType<Map<String, dynamic>>()
          .map(Habit.fromJson)
          .toList(),
      filePath: json['filePath'] as String?,
      savedAt: savedAtRaw == null ? null : DateTime.tryParse(savedAtRaw),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': 2,
      'savedAt': (savedAt ?? DateTime.now()).toIso8601String(),
      if (filePath != null) 'filePath': filePath,
      'habits': habits.map((habit) => habit.toJson()).toList(),
    };
  }
}
