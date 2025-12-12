import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'models/backup_v1.dart';
import 'services/storage_service.dart';
import 'services/backup_service.dart';

void main() {
  runApp(const DailyRoutineApp());
}

class DailyRoutineApp extends StatelessWidget {
  const DailyRoutineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Routine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansScTextTheme().apply(
          bodyColor: Colors.brown[900],
          displayColor: Colors.brown[900],
        ),
      ),
      home: const HabitListPage(),
    );
  }
}

// 习惯数据模型
class Habit {
  final String id;
  final String name;
  final IconData icon;
  final String iconName;
  final Color color;
  final Set<DateTime> checkedDates;

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.iconName,
    Color? color,
    Set<DateTime>? checkedDates,
  })  : color = color ?? const Color(0xFFFFD700),
        checkedDates = checkedDates ?? {};

  // 检查某一天是否已打卡
  bool isCheckedOn(DateTime date) {
    return checkedDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  // 切换某一天的打卡状态
  void toggleCheck(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (isCheckedOn(date)) {
      checkedDates.removeWhere((d) =>
          d.year == date.year && d.month == date.month && d.day == date.day);
    } else {
      checkedDates.add(normalizedDate);
    }
  }

  // 转换为备份格式
  HabitBackup toBackup() {
    return HabitBackup(
      id: id,
      title: name,
      icon: iconName,
      color: '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}',
      records: HabitBackup.fromDateTimeSet(checkedDates),
    );
  }

  // 从备份格式创建
  static Habit fromBackup(HabitBackup backup) {
    // Parse icon
    IconData icon = Icons.check_circle_rounded;
    String iconName = backup.icon ?? 'check_circle_rounded';
    try {
      icon = _parseIconName(iconName);
    } catch (e) {
      icon = Icons.check_circle_rounded;
      iconName = 'check_circle_rounded';
    }

    // Parse color
    Color color = const Color(0xFFFFD700);
    if (backup.color != null) {
      try {
        final hexColor = backup.color!.replaceAll('#', '');
        color = Color(int.parse('FF$hexColor', radix: 16));
      } catch (e) {
        color = const Color(0xFFFFD700);
      }
    }

    return Habit(
      id: backup.id,
      name: backup.title,
      icon: icon,
      iconName: iconName,
      color: color,
      checkedDates: backup.toDateTimeSet(),
    );
  }

  // Parse icon name to IconData
  static IconData _parseIconName(String iconName) {
    final iconMap = {
      'shower_rounded': Icons.shower_rounded,
      'pets_rounded': Icons.pets_rounded,
      'menu_book_rounded': Icons.menu_book_rounded,
      'fitness_center_rounded': Icons.fitness_center_rounded,
      'check_circle_rounded': Icons.check_circle_rounded,
    };
    return iconMap[iconName] ?? Icons.check_circle_rounded;
  }
}

// 习惯列表页面
class HabitListPage extends StatefulWidget {
  const HabitListPage({super.key});

  @override
  State<HabitListPage> createState() => _HabitListPageState();
}

class _HabitListPageState extends State<HabitListPage> {
  List<Habit> habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  // 加载习惯数据
  Future<void> _loadHabits() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final backup = await StorageService.loadHabits();
      if (backup != null && backup.habits.isNotEmpty) {
        setState(() {
          habits = backup.habits.map((h) => Habit.fromBackup(h)).toList();
          _isLoading = false;
        });
      } else {
        // 使用默认习惯
        setState(() {
          habits = _getDefaultHabits();
          _isLoading = false;
        });
        // 保存默认习惯
        await _saveHabits();
      }
    } catch (e) {
      print('Failed to load habits: $e');
      setState(() {
        habits = _getDefaultHabits();
        _isLoading = false;
      });
    }
  }

  // 获取默认习惯
  List<Habit> _getDefaultHabits() {
    return [
      Habit(
        id: 'habit_${DateTime.now().millisecondsSinceEpoch}',
        name: '洗澡',
        icon: Icons.shower_rounded,
        iconName: 'shower_rounded',
        color: const Color(0xFFFFD700),
      ),
      Habit(
        id: 'habit_${DateTime.now().millisecondsSinceEpoch + 1}',
        name: '给猫咪铲屎',
        icon: Icons.pets_rounded,
        iconName: 'pets_rounded',
        color: const Color(0xFFFF8C00),
      ),
      Habit(
        id: 'habit_${DateTime.now().millisecondsSinceEpoch + 2}',
        name: '阅读 30 分钟',
        icon: Icons.menu_book_rounded,
        iconName: 'menu_book_rounded',
        color: const Color(0xFF4CAF50),
      ),
      Habit(
        id: 'habit_${DateTime.now().millisecondsSinceEpoch + 3}',
        name: '运动健身',
        icon: Icons.fitness_center_rounded,
        iconName: 'fitness_center_rounded',
        color: const Color(0xFF2196F3),
      ),
    ];
  }

  // 保存习惯数据
  Future<void> _saveHabits() async {
    try {
      final backup = BackupV1(
        exportedAt: DateTime.now(),
        habits: habits.map((h) => h.toBackup()).toList(),
      );
      await StorageService.saveHabits(backup);
    } catch (e) {
      print('Failed to save habits: $e');
    }
  }

  // 导出备份
  Future<void> _exportBackup() async {
    try {
      final backup = BackupV1(
        exportedAt: DateTime.now(),
        habits: habits.map((h) => h.toBackup()).toList(),
      );
      await BackupService.exportBackup(backup);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('备份导出成功！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  // 导入备份
  Future<void> _importBackup() async {
    try {
      final backup = await BackupService.importBackup();
      setState(() {
        habits = backup.habits.map((h) => Habit.fromBackup(h)).toList();
      });
      await _saveHabits();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('备份导入成功！')),
        );
      }
    } on FormatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // 背景层
          const _WarmSunsetBackground(),

          // 3D 装饰元素
          const _Decorative3DElements(),

          // 主要内容
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 头部带设置按钮
                  Row(
                    children: [
                      Expanded(child: const _LuxuryGlassHeader()),
                      const SizedBox(width: 12),
                      _SettingsButton(
                        onExport: _exportBackup,
                        onImport: _importBackup,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: habits.isEmpty
                        ? Center(
                            child: Text(
                              '暂无习惯，点击右下角添加',
                              style: GoogleFonts.notoSansSc(
                                color: Colors.brown[700],
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: habits.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 20),
                            itemBuilder: (context, index) {
                              return _HabitCard(
                                habit: habits[index],
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HabitDetailPage(
                                        habit: habits[index],
                                        onUpdate: () {
                                          setState(() {});
                                          _saveHabits();
                                        },
                                      ),
                                    ),
                                  );
                                  setState(() {});
                                  _saveHabits();
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: const _LuxuryAddButton(),
    );
  }
}

// 设置按钮
class _SettingsButton extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onImport;

  const _SettingsButton({
    required this.onExport,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.15),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: PopupMenuButton<String>(
            icon: Icon(Icons.settings_rounded, color: Colors.brown[900]),
            onSelected: (value) {
              if (value == 'export') {
                onExport();
              } else if (value == 'import') {
                onImport();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download_rounded, color: Colors.brown[900]),
                    const SizedBox(width: 12),
                    Text(
                      '导出备份',
                      style: GoogleFonts.notoSansSc(fontSize: 18),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload_rounded, color: Colors.brown[900]),
                    const SizedBox(width: 12),
                    Text(
                      '导入备份',
                      style: GoogleFonts.notoSansSc(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 习惯卡片组件
class _HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;

  const _HabitCard({
    required this.habit,
    required this.onTap,
  });

  int _getCheckedDaysThisMonth() {
    final now = DateTime.now();
    return habit.checkedDates
        .where((date) => date.year == now.year && date.month == now.month)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final checkedDays = _getCheckedDaysThisMonth();
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white.withOpacity(0.15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // 左侧图标
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          habit.color,
                          habit.color.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: habit.color.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      habit.icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // 右侧内容
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: GoogleFonts.notoSansSc(
                            color: Colors.brown[900],
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '本月已完成 $checkedDays/$daysInMonth 天',
                          style: GoogleFonts.notoSansSc(
                            color: Colors.brown[700]?.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 右侧箭头
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.brown[800]?.withOpacity(0.5),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 习惯详情页面（日历视图）
class HabitDetailPage extends StatefulWidget {
  final Habit habit;
  final VoidCallback onUpdate;

  const HabitDetailPage({
    super.key,
    required this.habit,
    required this.onUpdate,
  });

  @override
  State<HabitDetailPage> createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends State<HabitDetailPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景层
          const _WarmSunsetBackground(),

          // 3D 装饰元素
          const _Decorative3DElements(),

          // 主要内容
          SafeArea(
            child: Column(
              children: [
                // 顶部导航栏
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white.withOpacity(0.15),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              onPressed: () {
                                widget.onUpdate();
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.brown[900],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white.withOpacity(0.15),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          widget.habit.color,
                                          widget.habit.color.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                    child: Icon(
                                      widget.habit.icon,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    widget.habit.name,
                                    style: GoogleFonts.notoSansSc(
                                      color: Colors.brown[900],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 日历区域
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white.withOpacity(0.15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: TableCalendar(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            calendarFormat: CalendarFormat.month,
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            headerStyle: HeaderStyle(
                              titleCentered: true,
                              formatButtonVisible: false,
                              titleTextStyle: GoogleFonts.notoSansSc(
                                color: Colors.brown[900],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              leftChevronIcon: Icon(
                                Icons.chevron_left,
                                color: Colors.brown[800],
                              ),
                              rightChevronIcon: Icon(
                                Icons.chevron_right,
                                color: Colors.brown[800],
                              ),
                            ),
                            daysOfWeekStyle: DaysOfWeekStyle(
                              weekdayStyle: GoogleFonts.notoSansSc(
                                color: Colors.brown[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                              weekendStyle: GoogleFonts.notoSansSc(
                                color: Colors.brown[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            calendarStyle: CalendarStyle(
                              defaultTextStyle: GoogleFonts.notoSansSc(
                                color: Colors.brown[900],
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                              weekendTextStyle: GoogleFonts.notoSansSc(
                                color: Colors.brown[900],
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                              outsideTextStyle: GoogleFonts.notoSansSc(
                                color: Colors.brown[400],
                                fontSize: 18,
                              ),
                              todayDecoration: BoxDecoration(
                                color: const Color(0xFFFF8C00).withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: const BoxDecoration(
                                color: Color(0xFFFFD700),
                                shape: BoxShape.circle,
                              ),
                              markerDecoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                            ),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                                widget.habit.toggleCheck(selectedDay);
                              });
                            },
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                final isChecked = widget.habit.isCheckedOn(day);
                                return _CalendarDayCell(
                                  day: day,
                                  isChecked: isChecked,
                                  isToday: isSameDay(day, DateTime.now()),
                                  isSelected: isSameDay(day, _selectedDay),
                                );
                              },
                              todayBuilder: (context, day, focusedDay) {
                                final isChecked = widget.habit.isCheckedOn(day);
                                return _CalendarDayCell(
                                  day: day,
                                  isChecked: isChecked,
                                  isToday: true,
                                  isSelected: isSameDay(day, _selectedDay),
                                );
                              },
                              selectedBuilder: (context, day, focusedDay) {
                                final isChecked = widget.habit.isCheckedOn(day);
                                return _CalendarDayCell(
                                  day: day,
                                  isChecked: isChecked,
                                  isToday: isSameDay(day, DateTime.now()),
                                  isSelected: true,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 自定义日历单元格
class _CalendarDayCell extends StatelessWidget {
  final DateTime day;
  final bool isChecked;
  final bool isToday;
  final bool isSelected;

  const _CalendarDayCell({
    required this.day,
    required this.isChecked,
    required this.isToday,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isToday
            ? const Color(0xFFFF8C00).withOpacity(0.2)
            : isSelected
                ? const Color(0xFFFFD700).withOpacity(0.3)
                : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 日期数字
          Text(
            '${day.day}',
            style: GoogleFonts.notoSansSc(
              color: Colors.brown[900],
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),

          // 打卡对勾
          if (isChecked)
            Positioned(
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 温暖日落渐变背景
class _WarmSunsetBackground extends StatelessWidget {
  const _WarmSunsetBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF58E59),
            Color(0xFFEB7A47),
            Color(0xFFE86A3A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

// 3D 装饰元素层
class _Decorative3DElements extends StatelessWidget {
  const _Decorative3DElements();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 80,
          left: -50,
          child: Opacity(
            opacity: 0.6,
            child: _Decorative3DPlaceholder(
              size: 200,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ),
        Positioned(
          top: 40,
          right: -80,
          child: Opacity(
            opacity: 0.5,
            child: _Decorative3DPlaceholder(
              size: 280,
              color: const Color(0xFFD4AF37).withOpacity(0.4),
              isRing: true,
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -30,
          child: Opacity(
            opacity: 0.4,
            child: _Decorative3DPlaceholder(
              size: 150,
              color: const Color(0xFF8B4513).withOpacity(0.5),
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          right: 20,
          child: Opacity(
            opacity: 0.3,
            child: _Decorative3DPlaceholder(
              size: 100,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }
}

// 3D 元素占位符
class _Decorative3DPlaceholder extends StatelessWidget {
  final double size;
  final Color color;
  final bool isRing;

  const _Decorative3DPlaceholder({
    required this.size,
    required this.color,
    this.isRing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isRing) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color,
            width: size * 0.15,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.3),
          ],
        ),
      ),
    );
  }
}

// 奢华玻璃头部组件
class _LuxuryGlassHeader extends StatelessWidget {
  const _LuxuryGlassHeader();

  String _todayLabel() {
    final now = DateTime.now();
    return '${now.year} 年 ${now.month} 月 ${now.day} 日';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white.withOpacity(0.15),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _todayLabel(),
                style: GoogleFonts.notoSansSc(
                  color: Colors.brown[900]?.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '今天也要好好生活呀',
                style: GoogleFonts.notoSansSc(
                  color: Colors.brown[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Daily Routine · 日常习惯记录',
                style: GoogleFonts.notoSansSc(
                  color: Colors.brown[800]?.withOpacity(0.6),
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 奢华添加按钮
class _LuxuryAddButton extends StatelessWidget {
  const _LuxuryAddButton();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white.withOpacity(0.2),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () {
              // TODO: 弹出新建习惯对话框
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(
              Icons.add_rounded,
              color: Color(0xFF5D4037),
              size: 28,
            ),
            label: Text(
              '添加习惯',
              style: GoogleFonts.notoSansSc(
                color: Colors.brown[900],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
