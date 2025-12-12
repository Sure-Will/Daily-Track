import 'dart:convert';

/// Backup format version 1
/// See docs/backup_format_v1.md for detailed specification
class BackupV1 {
  final int version;
  final DateTime exportedAt;
  final List<HabitBackup> habits;

  BackupV1({
    this.version = 1,
    required this.exportedAt,
    required this.habits,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'exportedAt': exportedAt.toIso8601String(),
      'habits': habits.map((h) => h.toJson()).toList(),
    };
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create from JSON
  factory BackupV1.fromJson(Map<String, dynamic> json) {
    // Validate version
    final version = json['version'];
    if (version == null) {
      throw FormatException('Missing version field in backup file');
    }
    if (version is! int) {
      throw FormatException('Invalid version field type');
    }
    if (version != 1) {
      throw FormatException(
        'Unsupported backup version $version. This app supports version 1.',
      );
    }

    // Parse exportedAt
    final exportedAtStr = json['exportedAt'];
    if (exportedAtStr == null || exportedAtStr is! String) {
      throw FormatException('Missing or invalid exportedAt field');
    }
    final exportedAt = DateTime.parse(exportedAtStr);

    // Parse habits
    final habitsJson = json['habits'];
    if (habitsJson == null || habitsJson is! List) {
      throw FormatException('Missing or invalid habits field');
    }

    final habits = habitsJson.map((h) {
      if (h is! Map<String, dynamic>) {
        throw FormatException('Invalid habit object');
      }
      return HabitBackup.fromJson(h);
    }).toList();

    return BackupV1(
      version: version,
      exportedAt: exportedAt,
      habits: habits,
    );
  }

  /// Create from JSON string
  factory BackupV1.fromJsonString(String jsonString) {
    try {
      final json = jsonDecode(jsonString);
      if (json is! Map<String, dynamic>) {
        throw FormatException('Invalid JSON structure');
      }
      return BackupV1.fromJson(json);
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException('Invalid JSON: $e');
    }
  }
}

/// Habit backup model
class HabitBackup {
  final String id;
  final String title;
  final String? icon;
  final String? color;
  final Map<String, bool> records;

  HabitBackup({
    required this.id,
    required this.title,
    this.icon,
    this.color,
    required this.records,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      'records': records,
    };
  }

  /// Create from JSON
  factory HabitBackup.fromJson(Map<String, dynamic> json) {
    // Validate required fields
    final id = json['id'];
    if (id == null || id is! String || id.isEmpty) {
      throw FormatException('Missing or invalid habit id');
    }

    final title = json['title'];
    if (title == null || title is! String || title.isEmpty) {
      throw FormatException('Missing or invalid habit title');
    }

    // Optional fields
    final icon = json['icon'] as String?;
    final color = json['color'] as String?;

    // Parse records
    final recordsJson = json['records'];
    if (recordsJson == null || recordsJson is! Map) {
      throw FormatException('Missing or invalid habit records');
    }

    final records = <String, bool>{};
    recordsJson.forEach((key, value) {
      if (key is! String) {
        throw FormatException('Invalid record date format');
      }
      // Validate date format (YYYY-MM-DD)
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(key)) {
        // Skip invalid dates instead of throwing
        return;
      }
      if (value is bool) {
        records[key] = value;
      } else if (value == true || value == 'true') {
        records[key] = true;
      } else {
        records[key] = false;
      }
    });

    return HabitBackup(
      id: id,
      title: title,
      icon: icon,
      color: color,
      records: records,
    );
  }

  /// Convert to DateTime set (for app internal use)
  Set<DateTime> toDateTimeSet() {
    final result = <DateTime>{};
    records.forEach((dateStr, isChecked) {
      if (isChecked) {
        try {
          final date = DateTime.parse(dateStr);
          result.add(DateTime(date.year, date.month, date.day));
        } catch (e) {
          // Skip invalid dates
        }
      }
    });
    return result;
  }

  /// Create from DateTime set
  static Map<String, bool> fromDateTimeSet(Set<DateTime> dates) {
    final result = <String, bool>{};
    for (final date in dates) {
      final dateStr =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      result[dateStr] = true;
    }
    return result;
  }
}
