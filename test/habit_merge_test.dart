import 'package:flutter_test/flutter_test.dart';

import 'package:daily_track/models/habit.dart';
import 'package:daily_track/services/habit_merge.dart';

void main() {
  Habit habit(String id, List<String> dates, {String? title}) {
    return Habit(id: id, title: title ?? id, completedDates: dates);
  }

  group('mergeHabits', () {
    test('外部新增的打卡在本地保存时不丢失（Hermes 场景）', () {
      final base = [
        habit('shower', ['2026-06-03']),
      ];
      // 用户在 app 里勾了 6/10。
      final local = [
        habit('shower', ['2026-06-03', '2026-06-10']),
      ];
      // 与此同时 Hermes 往文件里写了 6/09。
      final remote = [
        habit('shower', ['2026-06-03', '2026-06-09']),
      ];

      final merged = mergeHabits(base: base, local: local, remote: remote);

      expect(merged.single.completedDates, [
        '2026-06-03',
        '2026-06-09',
        '2026-06-10',
      ]);
    });

    test('本地取消打卡不会被远端旧数据复活', () {
      final base = [
        habit('shower', ['2026-06-03', '2026-06-07']),
      ];
      final local = [
        habit('shower', ['2026-06-03']),
      ];
      final remote = [
        habit('shower', ['2026-06-03', '2026-06-07']),
      ];

      final merged = mergeHabits(base: base, local: local, remote: remote);

      expect(merged.single.completedDates, ['2026-06-03']);
    });

    test('本地删除习惯时即使远端有新打卡也保持删除', () {
      final base = [
        habit('shower', ['2026-06-03']),
        habit('fitness', ['2026-06-01']),
      ];
      final local = [
        habit('fitness', ['2026-06-01']),
      ];
      final remote = [
        habit('shower', ['2026-06-03', '2026-06-09']),
        habit('fitness', ['2026-06-01']),
      ];

      final merged = mergeHabits(base: base, local: local, remote: remote);

      expect(merged.map((item) => item.id), ['fitness']);
    });

    test('外部新增的习惯保留', () {
      final base = [
        habit('fitness', ['2026-06-01']),
      ];
      final local = [
        habit('fitness', ['2026-06-01', '2026-06-10']),
      ];
      final remote = [
        habit('fitness', ['2026-06-01']),
        habit('reading', ['2026-06-09']),
      ];

      final merged = mergeHabits(base: base, local: local, remote: remote);

      expect(merged.map((item) => item.id), ['fitness', 'reading']);
      expect(merged.first.completedDates, ['2026-06-01', '2026-06-10']);
    });

    test('远端改名在本地未改名时保留，本地改名优先', () {
      final base = [
        habit('shower', const [], title: '洗澡'),
        habit('fitness', const [], title: '健身'),
      ];
      final local = [
        habit('shower', const [], title: '洗澡'),
        habit('fitness', const [], title: '撸铁'),
      ];
      final remote = [
        habit('shower', const [], title: '洗热水澡'),
        habit('fitness', const [], title: '健身'),
      ];

      final merged = mergeHabits(base: base, local: local, remote: remote);

      expect(merged[0].title, '洗热水澡');
      expect(merged[1].title, '撸铁');
    });

    test('远端与本地一致时合并结果等于本地', () {
      final base = [
        habit('fitness', ['2026-06-01']),
      ];
      final local = [
        habit('fitness', ['2026-06-01', '2026-06-10']),
      ];

      final merged = mergeHabits(base: base, local: local, remote: base);

      expect(merged.single.completedDates, ['2026-06-01', '2026-06-10']);
    });
  });
}
