import 'dart:ui';
import 'package:flutter/material.dart';

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
        fontFamily: 'SF Pro',
      ),
      home: const DailyHomePage(),
    );
  }
}

class DailyHomePage extends StatelessWidget {
  const DailyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final habits = [
      '早起 6:30',
      '阅读 30 分钟',
      '运动 20 分钟',
      '不刷短视频',
    ];

    return Scaffold(
      body: Stack(
        children: [
          // 🎨 背景层：温暖日落渐变
          const _WarmSunsetBackground(),

          // 🎭 3D 装饰元素层（位于背景之上，内容之下）
          const _Decorative3DElements(),

          // 📱 主要内容层
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _LuxuryGlassHeader(),
                  const SizedBox(height: 32),
                  Expanded(
                    child: ListView.separated(
                      itemCount: habits.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        return LuxuryGlassHabitCard(
                          title: habits[index],
                          progress: 0.3 + index * 0.2 > 1
                              ? 1
                              : 0.3 + index * 0.2,
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

// 🎨 温暖日落渐变背景
class _WarmSunsetBackground extends StatelessWidget {
  const _WarmSunsetBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF58E59), // 暖橙色
            Color(0xFFEB7A47), // 中间过渡
            Color(0xFFE86A3A), // 深橘红色
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

// 🎭 3D 装饰元素层
class _Decorative3DElements extends StatelessWidget {
  const _Decorative3DElements();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 大理石球体 - 左上角
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

        // 金属环 - 右上角
        Positioned(
          top: 40,
          right: -80,
          child: Opacity(
            opacity: 0.5,
            child: _Decorative3DPlaceholder(
              size: 280,
              color: const Color(0xFFD4AF37).withOpacity(0.4), // 金色
              isRing: true,
            ),
          ),
        ),

        // 石质球体 - 左下角
        Positioned(
          bottom: 100,
          left: -30,
          child: Opacity(
            opacity: 0.4,
            child: _Decorative3DPlaceholder(
              size: 150,
              color: const Color(0xFF8B4513).withOpacity(0.5), // 暗红棕色
            ),
          ),
        ),

        // 小装饰球 - 右下角
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

// 3D 元素占位符（在获得真实素材前使用）
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

// 🏆 奢华玻璃头部组件
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.brown[900]?.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '今天也要好好生活呀',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.brown[900],
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Daily Routine · 日常习惯记录',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.brown[800]?.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 💎 奢华玻璃习惯卡片
class LuxuryGlassHabitCard extends StatelessWidget {
  final String title;
  final double progress;

  const LuxuryGlassHabitCard({
    super.key,
    required this.title,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
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
              // 左侧渐变图标
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFD700), // 金色
                      Color(0xFFFF8C00), // 深橙色
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
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
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.brown[900],
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // 精致进度条
                    Stack(
                      children: [
                        // 背景轨道
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                        // 进度条
                        FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFFD700), // 金色
                                  Color(0xFFFF8C00), // 深橙色
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),
                    Text(
                      '${(progress * 100).toInt()}% 完成',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.brown[700]?.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
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

// ➕ 奢华添加按钮
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
              color: Color(0xFF5D4037), // 深棕色
              size: 28,
            ),
            label: Text(
              '添加习惯',
              style: TextStyle(
                color: Colors.brown[900],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
