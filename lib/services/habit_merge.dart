import '../models/habit.dart';

/// Three-way merge for whole-file saves with multiple writers (the app plus
/// external tools writing the same JSON, e.g. the Telegram bridge).
///
/// `base` is the state the user's edit started from, `local` is the user's
/// intended new state, and `remote` is what the store holds right now. The
/// local edit wins for the habit set and for fields the user actually
/// changed; remote-only changes (check-ins or renames made elsewhere while
/// the user was editing) are preserved instead of being overwritten.
List<Habit> mergeHabits({
  required List<Habit> base,
  required List<Habit> local,
  required List<Habit> remote,
}) {
  final baseById = {for (final habit in base) habit.id: habit};
  final localIds = {for (final habit in local) habit.id};
  final remoteById = {for (final habit in remote) habit.id: habit};

  final merged = <Habit>[
    for (final localHabit in local)
      switch (remoteById[localHabit.id]) {
        null => localHabit,
        final remoteHabit => _mergeHabit(
          base: baseById[localHabit.id],
          local: localHabit,
          remote: remoteHabit,
        ),
      },
  ];

  // Habits added externally while the user was editing are unknown to both
  // base and local, so the local edit cannot have deleted them — keep them.
  // Habits in base but missing from local were deleted by the user; their
  // absence here is intentional.
  for (final remoteHabit in remote) {
    if (!localIds.contains(remoteHabit.id) &&
        !baseById.containsKey(remoteHabit.id)) {
      merged.add(remoteHabit);
    }
  }

  return merged;
}

Habit _mergeHabit({
  required Habit? base,
  required Habit local,
  required Habit remote,
}) {
  final baseDates = {...?base?.completedDates};
  final localDates = {...local.completedDates};
  final addedLocally = localDates.difference(baseDates);
  final removedLocally = baseDates.difference(localDates);

  final dates = {...remote.completedDates}
    ..addAll(addedLocally)
    ..removeAll(removedLocally);

  final keptTitle = base != null && local.title == base.title
      ? remote.title
      : local.title;

  return local.copyWith(
    title: keptTitle,
    completedDates: dates.toList()..sort(),
  );
}
