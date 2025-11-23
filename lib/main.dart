import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

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
        textTheme: GoogleFonts.outfitTextTheme().apply(
          bodyColor: const Color(0xFF2D1F16),
          displayColor: const Color(0xFF2D1F16),
        ),
      ),
      home: const HabitListPage(),
    );
  }
}

// --- 数据模型 ---
class Habit {
  final String id;
  final String name;
  final IconData icon;
  final Set<DateTime> checkedDates;

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    Set<DateTime>? checkedDates,
  }) : checkedDates = checkedDates ?? {};

  bool isCheckedOn(DateTime date) {
    return checkedDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  void toggleCheck(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (isCheckedOn(date)) {
      checkedDates.removeWhere((d) =>
          d.year == date.year && d.month == date.month && d.day == date.day);
    } else {
      checkedDates.add(normalizedDate);
    }
  }
}

// --- 核心工具组件：奢华玻璃容器 ---
class LuxuryGlassContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? borderColor;

  const LuxuryGlassContainer({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 30,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                width: width,
                height: height,
                padding: padding,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.4),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: borderColor ?? Colors.white.withOpacity(0.3),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- 习惯列表页面 (主页面) ---
class HabitListPage extends StatefulWidget {
  const HabitListPage({super.key});

  @override
  State<HabitListPage> createState() => _HabitListPageState();
}

class _HabitListPageState extends State<HabitListPage> {
  // 1. 用户名状态
  String _username = "Alex";

  // 2. 习惯列表状态
  final List<Habit> habits = [
    Habit(id: '1', name: '晨间冥想', icon: Icons.self_improvement_rounded),
    Habit(id: '2', name: '阅读 30 分钟', icon: Icons.menu_book_rounded),
    Habit(id: '3', name: '喝水 2000ml', icon: Icons.local_drink_rounded),
    Habit(id: '4', name: '给猫咪铲屎', icon: Icons.pets_rounded),
  ];

  // 修改用户名的方法
  void _updateUsername(String newName) {
    setState(() {
      _username = newName;
    });
  }

  // 添加习惯的方法
  void _addNewHabit(String name, IconData icon) {
    setState(() {
      habits.add(Habit(
        id: DateTime.now().toString(), // 简单的 ID 生成
        name: name,
        icon: icon,
      ));
    });
  }

  // 显示设置对话框
  void _showSettingsDialog() {
    final TextEditingController controller = TextEditingController(text: _username);
    showDialog(
      context: context,
      builder: (context) => _GlassDialog(
        title: "设置",
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("修改昵称", style: GoogleFonts.outfit(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              style: GoogleFonts.outfit(fontSize: 18, color: const Color(0xFF2D1F16)),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    _updateUsername(controller.text);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D1F16),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text("保存修改", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 显示添加习惯对话框
  void _showAddHabitDialog() {
    final TextEditingController nameController = TextEditingController();
    IconData selectedIcon = Icons.star_rounded; // 默认图标

    // 可选图标列表
    final List<IconData> iconOptions = [
      Icons.star_rounded,
      Icons.fitness_center_rounded,
      Icons.code_rounded,
      Icons.book_rounded,
      Icons.music_note_rounded,
      Icons.bed_rounded,
      Icons.work_rounded,
      Icons.palette_rounded,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        // 使用 StatefulBuilder 为了在对话框内部刷新选中的图标
        builder: (context, setStateDialog) {
          return _GlassDialog(
            title: "创建新习惯",
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("习惯名称", style: GoogleFonts.outfit(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  style: GoogleFonts.outfit(fontSize: 18, color: const Color(0xFF2D1F16)),
                  decoration: InputDecoration(
                    hintText: "例如：早起跑步",
                    hintStyle: GoogleFonts.outfit(color: Colors.black26),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                Text("选择图标", style: GoogleFonts.outfit(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: iconOptions.map((icon) {
                    final isSelected = selectedIcon == icon;
                    return GestureDetector(
                      onTap: () {
                        setStateDialog(() {
                          selectedIcon = icon;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2D1F16) : Colors.white.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? Colors.white : const Color(0xFF5D4037),
                          size: 24,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        _addNewHabit(nameController.text, selectedIcon);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D1F16),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text("立即创建", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const _WarmSunsetBackground(),
          const _Decorative3DElements(),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // 头部传入动态用户名
                  _LuxuryGlassHeader(username: _username),
                  const SizedBox(height: 30),
                  
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 16),
                    child: Text(
                      "Your Habits",
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, 2), blurRadius: 4),
                        ]
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 120),
                      itemCount: habits.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _HabitCard(
                          habit: habits[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HabitDetailPage(
                                  habit: habits[index],
                                  onUpdate: () => setState(() {}),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // --- 左下角设置按钮 ---
          Positioned(
            left: 24,
            bottom: 40, 
            child: _SettingsButton(onTap: _showSettingsDialog),
          ),
        ],
      ),
      // --- 底部浮动按钮 (传入点击事件) ---
      floatingActionButton: _LuxuryAddButton(onPressed: _showAddHabitDialog),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// --- 组件：设置按钮 (左下角齿轮) ---
class _SettingsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SettingsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LuxuryGlassContainer(
      width: 56,
      height: 56,
      padding: EdgeInsets.zero,
      borderRadius: 18,
      onTap: onTap,
      child: const Center(
        child: Icon(
          Icons.settings_rounded,
          color: Color(0xFF2D1F16),
          size: 26,
        ),
      ),
    );
  }
}

// --- 组件：通用玻璃弹窗 ---
class _GlassDialog extends StatelessWidget {
  final String title;
  final Widget child;

  const _GlassDialog({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: LuxuryGlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D1F16),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.black54),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

// --- 习惯卡片组件 (保持不变) ---
class _HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;

  const _HabitCard({required this.habit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isDoneToday = habit.isCheckedOn(now);

    return LuxuryGlassContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE0B2), Color(0xFFFFB74D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB74D).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(habit.icon, color: const Color(0xFF5D4037), size: 26),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF2D1F16),
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isDoneToday ? '今日已完成' : '点击查看详情',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF5D4037).withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDoneToday ? const Color(0xFF4CAF50) : Colors.white.withOpacity(0.3),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            ),
            child: isDoneToday 
              ? const Icon(Icons.check, color: Colors.white, size: 18) 
              : null,
          )
        ],
      ),
    );
  }
}

// --- 详情页 (保持不变) ---
class HabitDetailPage extends StatefulWidget {
  final Habit habit;
  final VoidCallback onUpdate;

  const HabitDetailPage({super.key, required this.habit, required this.onUpdate});

  @override
  State<HabitDetailPage> createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends State<HabitDetailPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const _WarmSunsetBackground(),
          const _Decorative3DElements(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      LuxuryGlassContainer(
                        width: 50, height: 50,
                        padding: EdgeInsets.zero,
                        borderRadius: 16,
                        onTap: () {
                          widget.onUpdate();
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF2D1F16)),
                      ),
                      const Spacer(),
                      Text(
                        widget.habit.name,
                        style: GoogleFonts.outfit(
                          fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF2D1F16),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 50),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: LuxuryGlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      currentDay: DateTime.now(),
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      calendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        titleTextStyle: GoogleFonts.outfit(
                          fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF2D1F16),
                        ),
                        leftChevronIcon: const Icon(Icons.chevron_left, color: Color(0xFF2D1F16)),
                        rightChevronIcon: const Icon(Icons.chevron_right, color: Color(0xFF2D1F16)),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: GoogleFonts.outfit(color: const Color(0xFF5D4037), fontWeight: FontWeight.bold),
                        weekendStyle: GoogleFonts.outfit(color: const Color(0xFF5D4037), fontWeight: FontWeight.bold),
                      ),
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: GoogleFonts.outfit(color: const Color(0xFF2D1F16), fontSize: 16),
                        weekendTextStyle: GoogleFonts.outfit(color: const Color(0xFF2D1F16), fontSize: 16),
                        outsideTextStyle: GoogleFonts.outfit(color: const Color(0xFF2D1F16).withOpacity(0.4)),
                        todayDecoration: BoxDecoration(
                          color: const Color(0xFFFFB74D).withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.orangeAccent, blurRadius: 10, offset: Offset(0, 4))],
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

// --- 背景和装饰组件 (保持不变) ---
class _WarmSunsetBackground extends StatelessWidget {
  const _WarmSunsetBackground();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF9A9E), Color(0xFFFECFEF), Color(0xFFF6D365), Color(0xFFFDA085)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.3, 0.6, 1.0],
        ),
      ),
    );
  }
}

class _Decorative3DElements extends StatelessWidget {
  const _Decorative3DElements();
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: const [
        Positioned(
          top: 50, left: -40,
          child: _Simulated3DSphere(size: 180, color: Color(0xFFE0E0E0), opacity: 0.8, shadowColor: Color(0xFFD4AF37)),
        ),
        Positioned(
          top: 150, right: -60,
          child: _Simulated3DRing(size: 220, color: Color(0xFFFFD700)),
        ),
        Positioned(
          bottom: 120, left: -20,
          child: _Simulated3DSphere(size: 140, color: Color(0xFF8B0000), opacity: 0.9, shadowColor: Colors.black),
        ),
        Positioned(
          top: 300, left: 40,
          child: _Simulated3DSphere(size: 30, color: Color(0xFFB8860B), opacity: 0.6),
        ),
      ],
    );
  }
}

class _Simulated3DSphere extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  final Color shadowColor;
  const _Simulated3DSphere({required this.size, required this.color, this.opacity = 1.0, this.shadowColor = Colors.transparent});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: shadowColor.withOpacity(0.3), blurRadius: 30, offset: const Offset(10, 20))],
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), color.withOpacity(opacity * 0.6), color.withOpacity(opacity * 0.1)],
          center: const Alignment(-0.3, -0.3),
          radius: 0.8,
          focal: const Alignment(-0.3, -0.3),
        ),
      ),
    );
  }
}

class _Simulated3DRing extends StatelessWidget {
  final double size;
  final Color color;
  const _Simulated3DRing({required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: size * 0.12, color: color.withOpacity(0.3)),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withOpacity(0.1), color.withOpacity(0.0)]),
      ),
    );
  }
}

// --- 头部信息区 (接收 username) ---
class _LuxuryGlassHeader extends StatelessWidget {
  final String username; // 接收动态用户名

  const _LuxuryGlassHeader({required this.username});

  @override
  Widget build(BuildContext context) {
    return LuxuryGlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good Morning,', 
                    style: GoogleFonts.outfit(
                      fontSize: 16, color: const Color(0xFF2D1F16).withOpacity(0.7)
                    )
                  ),
                  Text(username, // 显示变量
                    style: GoogleFonts.outfit(
                      fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF2D1F16)
                    )
                  ),
                ],
              ),
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.5),
                  border: Border.all(color: Colors.white, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/150?img=47'),
                    fit: BoxFit.cover,
                  )
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '"The secret of your future is hidden in your daily routine."',
            style: GoogleFonts.caveat(
              fontSize: 22, 
              color: const Color(0xFF5D4037),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// --- 底部浮动按钮 (接收 onPressed) ---
class _LuxuryAddButton extends StatelessWidget {
  final VoidCallback onPressed; // 接收点击事件

  const _LuxuryAddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onPressed, // 绑定点击
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color(0xFF2D1F16).withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'New Habit',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
