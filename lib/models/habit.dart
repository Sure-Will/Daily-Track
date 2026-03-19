class Habit {
  const Habit({
    required this.id,
    required this.title,
    this.completedDates = const <String>[],
  });

  final String id;
  final String title;
  final List<String> completedDates;

  Habit copyWith({
    String? id,
    String? title,
    List<String>? completedDates,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      completedDates: completedDates ?? this.completedDates,
    );
  }

  bool isCompletedOn(DateTime date) {
    return completedDates.contains(dateKeyFor(date));
  }

  Habit toggleCompletionOn(DateTime date) {
    final key = dateKeyFor(date);
    final nextDates = {...completedDates};

    if (nextDates.contains(key)) {
      nextDates.remove(key);
    } else {
      nextDates.add(key);
    }

    final sortedDates = nextDates.toList()..sort();
    return copyWith(completedDates: sortedDates);
  }

  int completedCountInMonth(DateTime date) {
    final prefix =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-';
    return completedDates.where((item) => item.startsWith(prefix)).length;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completedDates': completedDates,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    final normalizedDates = _normalizeCompletedDates(json['completedDates']);
    final migratedDates = normalizedDates.isNotEmpty
        ? normalizedDates
        : _migrateLegacyProgress(json['progress']);

    return Habit(
      id: json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? '未命名习惯',
      completedDates: migratedDates,
    );
  }

  static List<String> _normalizeCompletedDates(Object? rawCompletedDates) {
    if (rawCompletedDates is! List<dynamic>) {
      return const <String>[];
    }

    final values = rawCompletedDates
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return values;
  }

  static List<String> _migrateLegacyProgress(Object? rawProgress) {
    if (rawProgress is! num || rawProgress.toDouble() < 1) {
      return const <String>[];
    }

    return <String>[dateKeyFor(DateTime.now())];
  }

  static String dateKeyFor(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final month = normalizedDate.month.toString().padLeft(2, '0');
    final day = normalizedDate.day.toString().padLeft(2, '0');

    return '${normalizedDate.year}-$month-$day';
  }
}
