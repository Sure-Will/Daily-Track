import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daily_routine/main.dart';
import 'package:daily_routine/models/habit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders the calendar-based habit dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DailyRoutineApp());
    await tester.pumpAndSettle();

    expect(find.text('记录日历'), findsOneWidget);
    expect(find.text('导入备份'), findsOneWidget);
    expect(find.text('导出备份'), findsOneWidget);
    expect(find.text('添加习惯'), findsOneWidget);

    expect(find.text('早起 6:30'), findsOneWidget);
    expect(find.text('阅读 30 分钟'), findsOneWidget);
    expect(find.text('运动 20 分钟'), findsOneWidget);
    expect(find.text('不刷短视频'), findsOneWidget);

    final todayKey = ValueKey('calendar-day-${Habit.dateKeyFor(DateTime.now())}');
    expect(find.byKey(todayKey), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('habit-toggle-wake-up')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('habit-toggle-wake-up')));
    await tester.pumpAndSettle();

    expect(find.text('已完成'), findsOneWidget);
  });
}
