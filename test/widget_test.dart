import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daily_track/main.dart';
import 'package:daily_track/models/habit.dart';
import 'package:daily_track/services/habit_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    setHabitBridgeDisabledForTesting(true);
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    setHabitBridgeDisabledForTesting(false);
  });

  testWidgets('renders the habit-first dashboard and per-habit calendar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DailyRoutineApp());
    await _pumpUi(tester);

    expect(find.text('今日习惯'), findsOneWidget);
    expect(find.text('添加习惯'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('导入备份'), findsNothing);
    expect(find.text('导出备份'), findsNothing);

    expect(find.text('健身'), findsOneWidget);
    expect(find.text('早起 6:30'), findsNothing);
    expect(find.text('阅读 30 分钟'), findsNothing);
    expect(find.text('运动 20 分钟'), findsNothing);
    expect(find.text('不刷短视频'), findsNothing);

    await tester.tap(find.text('设置'));
    await _pumpUi(tester);

    expect(find.text('主题配色'), findsOneWidget);
    expect(find.text('活力橙'), findsOneWidget);
    expect(find.text('暖橙、琥珀、夕阳'), findsOneWidget);
    expect(find.text('导入备份'), findsOneWidget);
    expect(find.text('导出备份'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await _pumpUi(tester);

    final today = DateTime.now();
    final todayKey = ValueKey('calendar-day-${Habit.dateKeyFor(today)}');

    await tester.tap(find.text('健身'));
    await _pumpUi(tester);

    expect(find.text('${today.year} 年 ${today.month} 月'), findsOneWidget);
    expect(find.byKey(todayKey), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await _pumpUi(tester);

    await tester.ensureVisible(
      find.byKey(const ValueKey('habit-toggle-fitness')),
    );
    await _pumpUi(tester);

    await tester.tap(find.byKey(const ValueKey('habit-toggle-fitness')));
    await _pumpUi(tester);

    expect(find.text('今天已完成'), findsOneWidget);
  });
}

Future<void> _pumpUi(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}
