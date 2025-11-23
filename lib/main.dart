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
        // 使用更现代、对比度更高的字体颜色配置
        textTheme: GoogleFonts.outfitTextTheme().apply( // 尝试 Outfit 或保持 NotoSans
          bodyColor: const Color(0xFF2D1F16), 
          displayColor: const Color(0xFF2D1F16),
        ),
      ),
      home: const HabitListPage(),
    );
  }
}

// --- 数据模型 (保持不变) ---
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

// --- 核心工具组件：奢华玻璃容器 (新增) ---
// 将玻璃效果封装，确保全应用统一的高级质感
class LuxuryGlassContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const LuxuryGlassContainer({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 30,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          // 增加模糊度以提升高级感
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
                  // 关键修改：使用渐变模拟光照反光，而非纯色透明
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.4),  // 左上角更亮，模拟光源
                      Colors.white.withOpacity(0.1),  // 右下角更透
                    ],
                  ),
                  // 关键修改：边框也带有细微的渐变感（这里用纯色模拟，但透明度极低）
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.0,
                  ),
                  // 可选：极淡的阴影增加层次
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

// --- 习惯列表页面 ---
class HabitListPage extends StatefulWidget {
  const HabitListPage({super.key});

  @override
  State<HabitListPage> createState() => _HabitListPageState();
}

class _HabitListPageState extends State<HabitListPage> {
  final List<Habit> habits = [
    Habit(id: '1', name: '晨间冥想', icon: Icons.self_improvement_rounded),
    Habit(id: '2', name: '阅读 30 分钟', icon: Icons.menu_book_rounded),
    Habit(id: '3', name: '喝水 2000ml', icon: Icons.local_drink_rounded),
    Habit(id: '4', name: '给猫咪铲屎', icon: Icons.pets_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 沉浸式顶部
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const _WarmSunsetBackground(),
          const _Decorative3DElements(), // 3D 元素层
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const _LuxuryGlassHeader(),
                  const SizedBox(height: 30),
                  
                  // 标题区
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 16),
                    child: Text(
                      "Your Habits",
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white, // 在深色背景上用白色，或深褐色
                        shadows: [
                          Shadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, 2), blurRadius: 4),
                        ]
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 100), // 为 FAB 留空
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
        ],
      ),
      floatingActionButton: const _LuxuryAddButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// --- 习惯卡片组件 (升级版) ---
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
          // 图标容器：升级为更有质感的渐变球
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // 模拟金色/橙色金属质感
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
          
          // 状态指示
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

// --- 详情页 (保持逻辑，升级UI) ---
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
                // 导航栏
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      // 返回按钮也做成毛玻璃
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
                      const SizedBox(width: 50), // 占位保持标题居中
                    ],
                  ),
                ),

                // 日历主体
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
                          color: const Color(0xFFFFB74D).withOpacity(0.5), // 柔和的今日高亮
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

// --- 视觉背景层 ---
class _WarmSunsetBackground extends StatelessWidget {
  const _WarmSunsetBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // 调整为更梦幻的夕阳渐变
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF9A9E), // 柔和粉
            Color(0xFFFECFEF), // 浅紫粉
            Color(0xFFF6D365), // 暖金
            Color(0xFFFDA085), // 橙红
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.3, 0.6, 1.0],
        ),
      ),
    );
  }
}

// --- 3D 装饰层 (代码模拟3D质感) ---
class _Decorative3DElements extends StatelessWidget {
  const _Decorative3DElements();

  @override
  Widget build(BuildContext context) {
    // 使用 Stack 和 Positioned 放置漂浮元素
    return Stack(
      clipBehavior: Clip.none,
      children: const [
        // 左上角大球（模拟大理石/珍珠）
        Positioned(
          top: 50, left: -40,
          child: _Simulated3DSphere(
            size: 180, 
            color: Color(0xFFE0E0E0), 
            opacity: 0.8,
            shadowColor: Color(0xFFD4AF37),
          ),
        ),
        // 右侧金属环（这里用空心圆模拟）
        Positioned(
          top: 150, right: -60,
          child: _Simulated3DRing(
            size: 220, 
            color: Color(0xFFFFD700), 
          ),
        ),
        // 底部深色球（模拟红石/深色星球）
        Positioned(
          bottom: 120, left: -20,
          child: _Simulated3DSphere(
            size: 140, 
            color: Color(0xFF8B0000), 
            opacity: 0.9,
            shadowColor: Colors.black,
          ),
        ),
        // 远处的微小球体
        Positioned(
          top: 300, left: 40,
          child: _Simulated3DSphere(
            size: 30, 
            color: Color(0xFFB8860B), 
            opacity: 0.6,
          ),
        ),
      ],
    );
  }
}

// 模拟 3D 球体（使用径向渐变模拟光照）
class _Simulated3DSphere extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  final Color shadowColor;

  const _Simulated3DSphere({
    required this.size, 
    required this.color, 
    this.opacity = 1.0,
    this.shadowColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: shadowColor.withOpacity(0.3), blurRadius: 30, offset: const Offset(10, 20)),
        ],
        // 关键：使用径向渐变模拟球体受光面
        gradient: RadialGradient(
          colors: [
            color.withOpacity(opacity),       // 高光点
            color.withOpacity(opacity * 0.6), // 中间调
            color.withOpacity(opacity * 0.1), // 阴影边缘（融入背景）
          ],
          center: const Alignment(-0.3, -0.3), // 光源在左上
          radius: 0.8,
          focal: const Alignment(-0.3, -0.3),
        ),
      ),
    );
  }
}

// 模拟 3D 环形
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
        // 简单的环形边框，带渐变色
        border: Border.all(
          width: size * 0.12,
          color: color.withOpacity(0.3), 
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.0),
          ]
        )
      ),
    );
  }
}

// --- 头部信息区 ---
class _LuxuryGlassHeader extends StatelessWidget {
  const _LuxuryGlassHeader();

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
                  Text('Alex', 
                    style: GoogleFonts.outfit(
                      fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF2D1F16)
                    )
                  ),
                ],
              ),
              // 用户头像占位
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.5),
                  border: Border.all(color: Colors.white, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/150?img=47'), // 示例头像
                    fit: BoxFit.cover,
                  )
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '"The secret of your future is hidden in your daily routine."',
            style: GoogleFonts.caveat( // 手写体增加艺术感
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

// --- 底部浮动按钮 ---
class _LuxuryAddButton extends StatelessWidget {
  const _LuxuryAddButton();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: const Color(0xFF2D1F16).withOpacity(0.8), // 深色按钮形成对比
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
    );
  }
}
