import 'dart:ui';

import 'package:flutter/material.dart';

import 'models/habit.dart';
import 'services/backup_io.dart';
import 'services/habit_storage.dart';

void main() {
  runApp(const DailyRoutineApp());
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

bool _isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

String _monthLabel(DateTime date) {
  return '${date.year} 年 ${date.month} 月';
}

String _weekdayLabel(int weekday) {
  const labels = <String>['一', '二', '三', '四', '五', '六', '日'];
  return labels[weekday - 1];
}

String _selectedDateLabel(DateTime date) {
  return '${date.month} 月 ${date.day} 日 周${_weekdayLabel(date.weekday)}';
}

class DailyRoutineApp extends StatelessWidget {
  const DailyRoutineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '每日追踪',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro',
      ),
      home: const DailyHomePage(),
    );
  }
}

class DailyHomePage extends StatefulWidget {
  const DailyHomePage({super.key});

  @override
  State<DailyHomePage> createState() => _DailyHomePageState();
}

class _DailyHomePageState extends State<DailyHomePage> {
  final HabitStorage _storage = HabitStorage();

  late DateTime _selectedDate;
  late DateTime _displayMonth;

  List<Habit> _habits = const <Habit>[];
  bool _isLoading = true;
  bool _isImporting = false;
  bool _isExporting = false;
  DateTime? _lastSavedAt;

  @override
  void initState() {
    super.initState();

    final today = _dateOnly(DateTime.now());
    _selectedDate = today;
    _displayMonth = DateTime(today.year, today.month);
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await _storage.loadHabits();
    if (!mounted) {
      return;
    }

    setState(() {
      _habits = habits;
      _isLoading = false;
    });
  }

  Future<void> _persistHabits(
    List<Habit> habits, {
    String? successMessage,
  }) async {
    setState(() {
      _habits = habits;
    });

    await _storage.saveHabits(habits);
    if (!mounted) {
      return;
    }

    setState(() {
      _lastSavedAt = DateTime.now();
    });

    if (successMessage != null) {
      _showMessage(successMessage);
    }
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = _dateOnly(date);
      _displayMonth = DateTime(date.year, date.month);
    });
  }

  void _changeMonth(int offset) {
    final nextMonth = DateTime(_displayMonth.year, _displayMonth.month + offset);
    final normalizedNextMonth = DateTime(nextMonth.year, nextMonth.month);
    final today = _dateOnly(DateTime.now());

    setState(() {
      _displayMonth = normalizedNextMonth;
      if (_selectedDate.year != normalizedNextMonth.year ||
          _selectedDate.month != normalizedNextMonth.month) {
        _selectedDate = today.year == normalizedNextMonth.year &&
                today.month == normalizedNextMonth.month
            ? today
            : normalizedNextMonth;
      }
    });
  }

  Future<void> _addHabit() async {
    final title = await _openHabitDialog();
    if (title == null || title.isEmpty) {
      return;
    }

    final nextHabits = <Habit>[
      ..._habits,
      Habit(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
      ),
    ];

    await _persistHabits(nextHabits, successMessage: '已添加习惯');
  }

  Future<void> _editHabit(Habit habit) async {
    final title = await _openHabitDialog(initialTitle: habit.title);
    if (title == null || title.isEmpty) {
      return;
    }

    final nextHabits = _habits
        .map((item) => item.id == habit.id ? item.copyWith(title: title) : item)
        .toList();

    await _persistHabits(nextHabits, successMessage: '已更新习惯');
  }

  Future<void> _deleteHabit(Habit habit) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('删除这个习惯？'),
              content: Text('“${habit.title}” 会从当前浏览器本地数据中移除。'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('删除'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }

    final nextHabits =
        _habits.where((item) => item.id != habit.id).toList(growable: false);
    await _persistHabits(nextHabits, successMessage: '已删除习惯');
  }

  Future<void> _toggleHabitOnSelectedDate(Habit habit) async {
    final nextHabits = _habits
        .map(
          (item) => item.id == habit.id
              ? item.toggleCompletionOn(_selectedDate)
              : item,
        )
        .toList();

    final nextStatus = !habit.isCompletedOn(_selectedDate);
    await _persistHabits(
      nextHabits,
      successMessage: nextStatus ? '已记录完成' : '已取消完成',
    );
  }

  Future<void> _importHabits() async {
    if (!backupIoSupported) {
      _showMessage('当前平台暂不支持网页导入');
      return;
    }

    setState(() {
      _isImporting = true;
    });

    try {
      final content = await importBackupFile();
      if (content == null) {
        return;
      }

      final habits = _storage.parseImportPayload(content);
      await _persistHabits(
        habits,
        successMessage: '导入成功，已恢复 ${habits.length} 条习惯',
      );
    } on FormatException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('导入失败，请确认文件是有效的 JSON 备份');
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  Future<void> _exportHabits() async {
    if (!backupIoSupported) {
      _showMessage('当前平台暂不支持网页导出');
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final payload = _storage.buildExportPayload(_habits);
      final today = DateTime.now().toIso8601String().split('T').first;

      await exportBackupFile(
        fileName: 'daily-routine-backup-$today.json',
        content: payload,
      );

      _showMessage('已导出 JSON 备份');
    } catch (_) {
      _showMessage('导出失败，请稍后再试');
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<String?> _openHabitDialog({String? initialTitle}) async {
    final controller = TextEditingController(text: initialTitle ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(initialTitle == null ? '添加习惯' : '编辑习惯'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '习惯名称',
              hintText: '例如：阅读 30 分钟',
            ),
            onSubmitted: (value) {
              Navigator.of(dialogContext).pop(value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _savedLabel() {
    if (_lastSavedAt == null) {
      return '自动保存在当前浏览器';
    }

    final hour = _lastSavedAt!.hour.toString().padLeft(2, '0');
    final minute = _lastSavedAt!.minute.toString().padLeft(2, '0');
    return '自动保存在当前浏览器 · 最后保存 $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _habits
        .where((habit) => habit.isCompletedOn(_selectedDate))
        .length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _GlassFloatingButton(
        onPressed: _addHabit,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2A120B),
              Color(0xFF7C2D12),
              Color(0xFFF97316),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -110,
              left: -70,
              child: _AmbientGlow(
                size: 320,
                colors: [
                  Color(0x55FDBA74),
                  Color(0x00FDBA74),
                ],
              ),
            ),
            const Positioned(
              right: -90,
              top: 90,
              child: _AmbientGlow(
                size: 300,
                colors: [
                  Color(0x55FB923C),
                  Color(0x00FB923C),
                ],
              ),
            ),
            const Positioned(
              left: 70,
              bottom: -120,
              child: _AmbientGlow(
                size: 360,
                colors: [
                  Color(0x44FCA5A5),
                  Color(0x00FCA5A5),
                ],
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Header(
                                selectedDate: _selectedDate,
                                completedCount: completedCount,
                                totalCount: _habits.length,
                                savedLabel: _savedLabel(),
                              ),
                              const SizedBox(height: 18),
                              _CalendarPanel(
                                displayMonth: _displayMonth,
                                selectedDate: _selectedDate,
                                onSelectDate: _selectDate,
                                onChangeMonth: _changeMonth,
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _GlassToolbarButton(
                                    label: '导入备份',
                                    icon: Icons.file_open_outlined,
                                    isBusy: _isImporting,
                                    onPressed: _isImporting ? null : _importHabits,
                                  ),
                                  _GlassToolbarButton(
                                    label: '导出备份',
                                    icon: Icons.download_rounded,
                                    isBusy: _isExporting,
                                    onPressed: _isExporting ? null : _exportHabits,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: switch (_isLoading) {
                                  true => const Padding(
                                      padding: EdgeInsets.only(top: 48),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  false when _habits.isEmpty => _EmptyState(
                                      selectedDate: _selectedDate,
                                    ),
                                  _ => ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _habits.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 16),
                                      itemBuilder: (context, index) {
                                        final habit = _habits[index];

                                        return GlassHabitCard(
                                          habit: habit,
                                          selectedDate: _selectedDate,
                                          onToggle: () =>
                                              _toggleHabitOnSelectedDate(habit),
                                          onEdit: () => _editHabit(habit),
                                          onDelete: () => _deleteHabit(habit),
                                        );
                                      },
                                    ),
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.selectedDate,
    required this.completedCount,
    required this.totalCount,
    required this.savedLabel,
  });

  final DateTime selectedDate;
  final int completedCount;
  final int totalCount;
  final String savedLabel;

  String _todayLabel() {
    final now = DateTime.now();
    return '${now.year} 年 ${now.month} 月 ${now.day} 日';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _todayLabel(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '每日追踪',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Every day counts.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
              ),
        ),
        const SizedBox(height: 18),
        _GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          borderRadius: 22,
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _InfoChip(
                label:
                    '${_selectedDateLabel(selectedDate)} · 已完成 $completedCount / $totalCount',
              ),
              _InfoChip(
                label: savedLabel,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CalendarPanel extends StatelessWidget {
  const _CalendarPanel({
    required this.displayMonth,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onChangeMonth,
  });

  final DateTime displayMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<int> onChangeMonth;

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final leadingEmptyCount = firstDayOfMonth.weekday - 1;
    final daysInMonth =
        DateUtils.getDaysInMonth(displayMonth.year, displayMonth.month);
    final today = _dateOnly(DateTime.now());

    final cells = <DateTime?>[
      ...List<DateTime?>.filled(leadingEmptyCount, null),
      for (var day = 1; day <= daysInMonth; day++)
        DateTime(displayMonth.year, displayMonth.month, day),
    ];

    final trailingEmptyCount = (7 - cells.length % 7) % 7;
    cells.addAll(List<DateTime?>.filled(trailingEmptyCount, null));

    return _GlassPanel(
      borderRadius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '记录日历',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              _MonthArrowButton(
                icon: Icons.chevron_left_rounded,
                onPressed: () => onChangeMonth(-1),
              ),
              const SizedBox(width: 8),
              Text(
                _monthLabel(displayMonth),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 8),
              _MonthArrowButton(
                icon: Icons.chevron_right_rounded,
                onPressed: () => onChangeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List<Widget>.generate(7, (index) {
              return Expanded(
                child: Center(
                  child: Text(
                    _weekdayLabel(index + 1),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white60,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final date = cells[index];
              if (date == null) {
                return const SizedBox.shrink();
              }

              return _CalendarDayCell(
                key: ValueKey('calendar-day-${Habit.dateKeyFor(date)}'),
                date: date,
                isToday: _isSameDay(date, today),
                isSelected: _isSameDay(date, selectedDate),
                onTap: () => onSelectDate(date),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MonthArrowButton extends StatelessWidget {
  const _MonthArrowButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    super.key,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected ? Colors.white : Colors.white70;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [
                      Color(0xFFF97316),
                      Color(0xFFFB7185),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white.withValues(alpha: 0.06),
            border: Border.all(
              color: isToday
                  ? Colors.white.withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isToday
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: const LinearGradient(
              colors: [
                Color(0x26FFFFFF),
                Color(0x0CFFFFFF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 36,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({
    required this.size,
    required this.colors,
  });

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

class _GlassToolbarButton extends StatelessWidget {
  const _GlassToolbarButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isBusy = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.6 : 1,
      child: _GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 20,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isBusy)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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

class _GlassFloatingButton extends StatelessWidget {
  const _GlassFloatingButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: EdgeInsets.zero,
      borderRadius: 22,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF97316),
                        Color(0xFFFB7185),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '添加习惯',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.selectedDate,
  });

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: _GlassPanel(
          padding: const EdgeInsets.all(28),
          borderRadius: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF97316),
                      Color(0xFFFB7185),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '还没有习惯',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '先创建习惯，再在 ${_selectedDateLabel(selectedDate)} 这一天点一下打卡。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassHabitCard extends StatelessWidget {
  const GlassHabitCard({
    super.key,
    required this.habit,
    required this.selectedDate,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Habit habit;
  final DateTime selectedDate;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isCompleted = habit.isCompletedOn(selectedDate);
    final completedThisMonth = habit.completedCountInMonth(selectedDate);

    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                key: ValueKey('habit-toggle-${habit.id}'),
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isCompleted
                        ? const LinearGradient(
                            colors: [
                              Color(0xFFF97316),
                              Color(0xFFFB7185),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color:
                        isCompleted ? null : Colors.white.withValues(alpha: 0.08),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            habit.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _StatusChip(
                          label: isCompleted ? '已完成' : '未完成',
                          isCompleted: isCompleted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_selectedDateLabel(selectedDate)} · 点左侧圆点即可记录这一天是否完成',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white60,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricChip(label: '本月完成 $completedThisMonth 天'),
              _MetricChip(label: '累计记录 ${habit.completedDates.length} 天'),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _GlassActionButton(
                onPressed: onToggle,
                icon: isCompleted
                    ? Icons.remove_done_rounded
                    : Icons.check_circle_outline_rounded,
                label: isCompleted ? '取消完成' : '记为完成',
              ),
              _GlassActionButton(
                onPressed: onEdit,
                icon: Icons.edit_outlined,
                label: '编辑',
              ),
              _GlassActionButton(
                onPressed: onDelete,
                icon: Icons.delete_outline,
                label: '删除',
                foregroundColor: Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.isCompleted,
  });

  final String label;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: isCompleted
            ? const LinearGradient(
                colors: [
                  Color(0xFFF97316),
                  Color(0xFFFB7185),
                ],
              )
            : null,
        color: isCompleted ? null : Colors.white.withValues(alpha: 0.08),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
      ),
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  const _GlassActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.foregroundColor = Colors.white,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: foregroundColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w600,
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
