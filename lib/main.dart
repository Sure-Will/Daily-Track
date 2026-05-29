import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/habit.dart';
import 'services/backup_io.dart';
import 'services/habit_storage.dart';

const _brandOrange = Color(0xFFF97316);
const _brandOrangeDark = Color(0xFFEA580C);
const _brandAmber = Color(0xFFF59E0B);
const _themePreferenceKey = 'daily_track_theme';

enum DailyThemeChoice { ember, pureLight, deepDark }

class DailyThemeSpec {
  const DailyThemeSpec({
    required this.choice,
    required this.name,
    required this.caption,
    required this.brightness,
    required this.seed,
    required this.accent,
    required this.accentStrong,
    required this.accentAlt,
    required this.ink,
    required this.inkMuted,
    required this.canvas,
    required this.panel,
    required this.panelAlt,
    required this.backgroundColors,
    required this.washColors,
    required this.onBackground,
    required this.onBackgroundMuted,
    required this.onBackgroundSoft,
    required this.glassTop,
    required this.glassBottom,
    required this.glassBorder,
    required this.glassShadow,
    required this.glassControl,
    required this.cardControl,
    required this.chipSurface,
    required this.chipBorder,
    required this.dayCellSurface,
    required this.dayCellBorder,
  });

  final DailyThemeChoice choice;
  final String name;
  final String caption;
  final Brightness brightness;
  final Color seed;
  final Color accent;
  final Color accentStrong;
  final Color accentAlt;
  final Color ink;
  final Color inkMuted;
  final Color canvas;
  final Color panel;
  final Color panelAlt;
  final List<Color> backgroundColors;
  final List<List<Color>> washColors;
  final Color onBackground;
  final Color onBackgroundMuted;
  final Color onBackgroundSoft;
  final Color glassTop;
  final Color glassBottom;
  final Color glassBorder;
  final Color glassShadow;
  final Color glassControl;
  final Color cardControl;
  final Color chipSurface;
  final Color chipBorder;
  final Color dayCellSurface;
  final Color dayCellBorder;

  ThemeData materialTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
      ),
      fontFamily: 'SF Pro',
      scaffoldBackgroundColor: backgroundColors.last,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accentStrong),
      ),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelStyle: TextStyle(color: accentStrong),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentStrong, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xFF111827)
            : const Color(0xFF172033),
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}

DailyThemeSpec _themeFor(DailyThemeChoice choice) {
  return switch (choice) {
    DailyThemeChoice.ember => const DailyThemeSpec(
      choice: DailyThemeChoice.ember,
      name: '活力橙',
      caption: '暖橙、琥珀、夕阳',
      brightness: Brightness.dark,
      seed: _brandOrange,
      accent: _brandOrange,
      accentStrong: _brandOrangeDark,
      accentAlt: _brandAmber,
      ink: Color(0xFFFFF1E6),
      inkMuted: Color(0xB8FFF1E6),
      canvas: Color(0xFF3E180D),
      panel: Color(0xFF5A2614),
      panelAlt: Color(0xFF4E2113),
      backgroundColors: [
        Color(0xFF6B2810),
        Color(0xFFB0431A),
        Color(0xFFF97316),
      ],
      washColors: [
        [Color(0x55FDBA74), Color(0x00FDBA74)],
        [Color(0x55FB923C), Color(0x00FB923C)],
        [Color(0x44FCA5A5), Color(0x00FCA5A5)],
      ],
      onBackground: Colors.white,
      onBackgroundMuted: Color(0xB3FFFFFF),
      onBackgroundSoft: Color(0x99FFFFFF),
      glassTop: Color(0x26FFFFFF),
      glassBottom: Color(0x0CFFFFFF),
      glassBorder: Color(0x29FFFFFF),
      glassShadow: Color(0x4D000000),
      glassControl: Color(0x24FFFFFF),
      cardControl: Color(0x14FFFFFF),
      chipSurface: Color(0xFF4E2113),
      chipBorder: Color(0xFF6E3A22),
      dayCellSurface: Color(0xFF4E2113),
      dayCellBorder: Color(0xFF6E3A22),
    ),
    DailyThemeChoice.pureLight => const DailyThemeSpec(
      choice: DailyThemeChoice.pureLight,
      name: '浅色主题',
      caption: '白瓷、银灰、清透蓝',
      brightness: Brightness.light,
      seed: Color(0xFF2563EB),
      accent: Color(0xFF2563EB),
      accentStrong: Color(0xFF1D4ED8),
      accentAlt: Color(0xFF06B6D4),
      ink: Color(0xFF111827),
      inkMuted: Color(0xA3111827),
      canvas: Color(0xFFF8FAFC),
      panel: Color(0xFFEFF6FF),
      panelAlt: Colors.white,
      backgroundColors: [
        Color(0xFFFFFFFF),
        Color(0xFFF4F8FF),
        Color(0xFFE4EDFF),
      ],
      washColors: [
        [Color(0x4AC4B5FD), Color(0x00C4B5FD)],
        [Color(0x4A67E8F9), Color(0x0067E8F9)],
        [Color(0x5C93C5FD), Color(0x0093C5FD)],
      ],
      onBackground: Color(0xFF111827),
      onBackgroundMuted: Color(0xB3111827),
      onBackgroundSoft: Color(0x8A111827),
      glassTop: Color(0xCCFFFFFF),
      glassBottom: Color(0x66FFFFFF),
      glassBorder: Color(0xBFE2E8F0),
      glassShadow: Color(0x1F0F172A),
      glassControl: Color(0xCCFFFFFF),
      cardControl: Color(0x80FFFFFF),
      chipSurface: Color(0xFFEFF6FF),
      chipBorder: Color(0xFFBFDBFE),
      dayCellSurface: Color(0xE6FFFFFF),
      dayCellBorder: Color(0xFFD8E2EF),
    ),
    DailyThemeChoice.deepDark => const DailyThemeSpec(
      choice: DailyThemeChoice.deepDark,
      name: '深色主题',
      caption: '墨黑、石墨、极光青',
      brightness: Brightness.dark,
      seed: Color(0xFF22D3EE),
      accent: Color(0xFF22D3EE),
      accentStrong: Color(0xFF67E8F9),
      accentAlt: Color(0xFFA78BFA),
      ink: Color(0xFFE5E7EB),
      inkMuted: Color(0xA3E5E7EB),
      canvas: Color(0xFF0B1120),
      panel: Color(0xFF111827),
      panelAlt: Color(0xFF172033),
      backgroundColors: [
        Color(0xFF020617),
        Color(0xFF0B1120),
        Color(0xFF111827),
      ],
      washColors: [
        [Color(0x3322D3EE), Color(0x0022D3EE)],
        [Color(0x2EA78BFA), Color(0x00A78BFA)],
        [Color(0x244ADE80), Color(0x004ADE80)],
      ],
      onBackground: Color(0xFFF8FAFC),
      onBackgroundMuted: Color(0xB3F8FAFC),
      onBackgroundSoft: Color(0x8AF8FAFC),
      glassTop: Color(0x2EFFFFFF),
      glassBottom: Color(0x1015B8A6),
      glassBorder: Color(0x38FFFFFF),
      glassShadow: Color(0x66000000),
      glassControl: Color(0x24FFFFFF),
      cardControl: Color(0x14FFFFFF),
      chipSurface: Color(0xFF172033),
      chipBorder: Color(0xFF273449),
      dayCellSurface: Color(0xFF111827),
      dayCellBorder: Color(0xFF263244),
    ),
  };
}

class _DailyThemeScope extends InheritedWidget {
  const _DailyThemeScope({required this.spec, required super.child});

  final DailyThemeSpec spec;

  static DailyThemeSpec of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_DailyThemeScope>();
    return scope?.spec ?? _themeFor(DailyThemeChoice.ember);
  }

  @override
  bool updateShouldNotify(_DailyThemeScope oldWidget) {
    return oldWidget.spec.choice != spec.choice;
  }
}

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

class DailyRoutineApp extends StatefulWidget {
  const DailyRoutineApp({super.key});

  @override
  State<DailyRoutineApp> createState() => _DailyRoutineAppState();
}

class _DailyRoutineAppState extends State<DailyRoutineApp> {
  DailyThemeChoice _themeChoice = DailyThemeChoice.ember;

  @override
  void initState() {
    super.initState();
    _loadThemeChoice();
  }

  Future<void> _loadThemeChoice() async {
    final preferences = await SharedPreferences.getInstance();
    final savedKey = preferences.getString(_themePreferenceKey);
    final savedChoice = DailyThemeChoice.values
        .where((choice) => choice.name == savedKey)
        .firstOrNull;

    if (savedChoice == null || !mounted) {
      return;
    }

    setState(() {
      _themeChoice = savedChoice;
    });
  }

  Future<void> _changeTheme(DailyThemeChoice choice) async {
    setState(() {
      _themeChoice = choice;
    });

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themePreferenceKey, choice.name);
  }

  @override
  Widget build(BuildContext context) {
    final spec = _themeFor(_themeChoice);

    return _DailyThemeScope(
      spec: spec,
      child: MaterialApp(
        title: '每日追踪',
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: child ?? const SizedBox.shrink(),
          );
        },
        theme: spec.materialTheme(),
        home: DailyHomePage(
          selectedTheme: _themeChoice,
          onThemeChanged: _changeTheme,
        ),
      ),
    );
  }
}

class DailyHomePage extends StatefulWidget {
  const DailyHomePage({
    super.key,
    required this.selectedTheme,
    required this.onThemeChanged,
  });

  final DailyThemeChoice selectedTheme;
  final ValueChanged<DailyThemeChoice> onThemeChanged;

  @override
  State<DailyHomePage> createState() => _DailyHomePageState();
}

class _DailyHomePageState extends State<DailyHomePage> {
  final HabitStorage _storage = HabitStorage();

  List<Habit> _habits = const <Habit>[];
  bool _isLoading = true;
  bool _isImporting = false;
  bool _isExporting = false;
  DateTime? _lastSavedAt;

  @override
  void initState() {
    super.initState();
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

  Future<void> _addHabit() async {
    final title = await _openHabitDialog();
    if (title == null || title.isEmpty) {
      return;
    }

    final nextHabits = <Habit>[
      ..._habits,
      Habit(id: DateTime.now().microsecondsSinceEpoch.toString(), title: title),
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
    final shouldDelete =
        await showDialog<bool>(
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

    final nextHabits = _habits
        .where((item) => item.id != habit.id)
        .toList(growable: false);
    await _persistHabits(nextHabits, successMessage: '已删除习惯');
  }

  Future<Habit> _toggleHabitOnDate(
    Habit habit,
    DateTime date, {
    bool showMessage = true,
  }) async {
    final targetDate = _dateOnly(date);
    final currentHabit = _habits.firstWhere(
      (item) => item.id == habit.id,
      orElse: () => habit,
    );
    final updatedHabit = currentHabit.toggleCompletionOn(targetDate);
    final nextHabits = _habits
        .map((item) => item.id == habit.id ? updatedHabit : item)
        .toList();

    final nextStatus = updatedHabit.isCompletedOn(targetDate);
    await _persistHabits(
      nextHabits,
      successMessage: showMessage ? (nextStatus ? '已记录完成' : '已取消完成') : null,
    );

    return updatedHabit;
  }

  Future<void> _toggleHabitToday(Habit habit) async {
    await _toggleHabitOnDate(habit, DateTime.now());
  }

  Future<void> _openHabitCalendar(Habit habit) async {
    final latestHabit = _habits.firstWhere(
      (item) => item.id == habit.id,
      orElse: () => habit,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _HabitCalendarDialog(
          habit: latestHabit,
          onToggleDate: (targetHabit, date) {
            return _toggleHabitOnDate(targetHabit, date, showMessage: false);
          },
        );
      },
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
        final theme = _DailyThemeScope.of(dialogContext);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
              decoration: BoxDecoration(
                color: theme.canvas,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: theme.glassShadow,
                    blurRadius: 36,
                    offset: Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    initialTitle == null ? '添加习惯' : '编辑习惯',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: theme.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    cursorColor: theme.accentStrong,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: theme.ink,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      labelText: '习惯名称',
                      hintText: '例如：阅读 30 分钟',
                    ),
                    onSubmitted: (value) {
                      Navigator.of(dialogContext).pop(value.trim());
                    },
                  ),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(
                            dialogContext,
                          ).pop(controller.text.trim());
                        },
                        child: const Text('保存'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
    final savedAt = _storage.bridgeSavedAt ?? _lastSavedAt;
    final target = _storage.bridgeConnected ? '本地 JSON' : '浏览器本地';

    if (savedAt == null) {
      return '自动保存到$target';
    }

    final hour = savedAt.hour.toString().padLeft(2, '0');
    final minute = savedAt.minute.toString().padLeft(2, '0');
    return '自动保存到$target · 最后保存 $hour:$minute';
  }

  String _syncTitle() {
    return _storage.bridgeConnected ? '本地 JSON 已连接' : '浏览器本地模式';
  }

  String _syncDetail() {
    return _storage.bridgeConnected
        ? (_storage.bridgeFilePath ?? 'data/daily-track.json')
        : '启动 dart run bin/daily_track_bridge.dart 后自动同步';
  }

  Future<void> _openSettings({
    required int completedCount,
    required int totalCount,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _SettingsDialog(
          completedCount: completedCount,
          totalCount: totalCount,
          savedLabel: _savedLabel(),
          syncTitle: _syncTitle(),
          syncDetail: _syncDetail(),
          isBridgeConnected: _storage.bridgeConnected,
          isImporting: _isImporting,
          isExporting: _isExporting,
          selectedTheme: widget.selectedTheme,
          onThemeChanged: widget.onThemeChanged,
          onImport: () {
            Navigator.of(dialogContext).pop();
            _importHabits();
          },
          onExport: () {
            Navigator.of(dialogContext).pop();
            _exportHabits();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _DailyThemeScope.of(context);
    final today = _dateOnly(DateTime.now());
    final completedCount = _habits
        .where((habit) => habit.isCompletedOn(today))
        .length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.backgroundColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -110,
              left: -70,
              child: _AmbientGlow(size: 320, colors: theme.washColors[0]),
            ),
            Positioned(
              right: -90,
              top: 90,
              child: _AmbientGlow(size: 300, colors: theme.washColors[1]),
            ),
            Positioned(
              left: 70,
              bottom: -120,
              child: _AmbientGlow(size: 360, colors: theme.washColors[2]),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 112),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Header(),
                              const SizedBox(height: 26),
                              _SectionHeader(
                                title: '今日习惯',
                                detail:
                                    '${_selectedDateLabel(today)} · $completedCount / ${_habits.length}',
                              ),
                              const SizedBox(height: 14),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: switch (_isLoading) {
                                  true => const Padding(
                                    padding: EdgeInsets.only(top: 48),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  false when _habits.isEmpty =>
                                    const _EmptyState(),
                                  _ => ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _habits.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      final habit = _habits[index];

                                      return GlassHabitCard(
                                        habit: habit,
                                        today: today,
                                        onOpenCalendar: () =>
                                            _openHabitCalendar(habit),
                                        onToggleToday: () =>
                                            _toggleHabitToday(habit),
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
            Positioned(
              left: 20,
              bottom: 20,
              child: SafeArea(
                child: _SettingsFloatingButton(
                  onPressed: () => _openSettings(
                    completedCount: completedCount,
                    totalCount: _habits.length,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: SafeArea(
                child: _GlassFloatingButton(onPressed: _addHabit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  String _todayLabel() {
    final now = DateTime.now();
    return '${now.year} 年 ${now.month} 月 ${now.day} 日';
  }

  @override
  Widget build(BuildContext context) {
    final theme = _DailyThemeScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _todayLabel(),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: theme.onBackgroundMuted),
        ),
        const SizedBox(height: 4),
        Text(
          '每日追踪',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: theme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Every day counts.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: theme.onBackgroundSoft),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = _DailyThemeScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: theme.onBackground,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          detail,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: theme.onBackgroundMuted,
            fontWeight: FontWeight.w600,
          ),
          softWrap: true,
        ),
      ],
    );
  }
}

class _HabitCalendarDialog extends StatefulWidget {
  const _HabitCalendarDialog({required this.habit, required this.onToggleDate});

  final Habit habit;
  final Future<Habit> Function(Habit habit, DateTime date) onToggleDate;

  @override
  State<_HabitCalendarDialog> createState() => _HabitCalendarDialogState();
}

class _HabitCalendarDialogState extends State<_HabitCalendarDialog> {
  late Habit _habit;
  late DateTime _displayMonth;
  late DateTime _selectedDate;
  String? _savingDateKey;

  @override
  void initState() {
    super.initState();

    final today = _dateOnly(DateTime.now());
    _habit = widget.habit;
    _selectedDate = today;
    _displayMonth = DateTime(today.year, today.month);
  }

  void _changeMonth(int offset) {
    final nextMonth = DateTime(
      _displayMonth.year,
      _displayMonth.month + offset,
    );
    final normalizedNextMonth = DateTime(nextMonth.year, nextMonth.month);
    final today = _dateOnly(DateTime.now());

    setState(() {
      _displayMonth = normalizedNextMonth;
      if (_selectedDate.year != normalizedNextMonth.year ||
          _selectedDate.month != normalizedNextMonth.month) {
        _selectedDate =
            today.year == normalizedNextMonth.year &&
                today.month == normalizedNextMonth.month
            ? today
            : normalizedNextMonth;
      }
    });
  }

  Future<void> _toggleDate(DateTime date) async {
    final normalizedDate = _dateOnly(date);
    final key = Habit.dateKeyFor(normalizedDate);
    setState(() {
      _selectedDate = normalizedDate;
      _savingDateKey = key;
    });

    final updatedHabit = await widget.onToggleDate(_habit, normalizedDate);
    if (!mounted) {
      return;
    }

    setState(() {
      _habit = updatedHabit;
      _savingDateKey = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = _DailyThemeScope.of(context);
    final selectedIsCompleted = _habit.isCompletedOn(_selectedDate);
    final completedThisMonth = _habit.completedCountInMonth(_displayMonth);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          decoration: BoxDecoration(
            color: theme.canvas,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: theme.glassShadow,
                blurRadius: 42,
                offset: Offset(0, 24),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _habit.title,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: theme.ink,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_selectedDateLabel(_selectedDate)} · ${selectedIsCompleted ? '已完成' : '未完成'}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: theme.inkMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: '关闭',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: theme.accentStrong,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _WarmMetricChip(label: '本月完成 $completedThisMonth 天'),
                    _WarmMetricChip(
                      label: '累计记录 ${_habit.completedDates.length} 天',
                    ),
                    _WarmMetricChip(label: '点日期切换打卡'),
                  ],
                ),
                const SizedBox(height: 18),
                _CalendarPanel(
                  displayMonth: _displayMonth,
                  selectedDate: _selectedDate,
                  habit: _habit,
                  savingDateKey: _savingDateKey,
                  onToggleDate: _toggleDate,
                  onChangeMonth: _changeMonth,
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('完成'),
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

class _CalendarPanel extends StatelessWidget {
  const _CalendarPanel({
    required this.displayMonth,
    required this.selectedDate,
    required this.habit,
    required this.savingDateKey,
    required this.onToggleDate,
    required this.onChangeMonth,
  });

  final DateTime displayMonth;
  final DateTime selectedDate;
  final Habit habit;
  final String? savingDateKey;
  final ValueChanged<DateTime> onToggleDate;
  final ValueChanged<int> onChangeMonth;

  @override
  Widget build(BuildContext context) {
    final theme = _DailyThemeScope.of(context);
    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final leadingEmptyCount = firstDayOfMonth.weekday - 1;
    final daysInMonth = DateUtils.getDaysInMonth(
      displayMonth.year,
      displayMonth.month,
    );
    final today = _dateOnly(DateTime.now());

    final cells = <DateTime?>[
      ...List<DateTime?>.filled(leadingEmptyCount, null),
      for (var day = 1; day <= daysInMonth; day++)
        DateTime(displayMonth.year, displayMonth.month, day),
    ];

    final trailingEmptyCount = (7 - cells.length % 7) % 7;
    cells.addAll(List<DateTime?>.filled(trailingEmptyCount, null));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _monthLabel(displayMonth),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: theme.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            _MonthArrowButton(
              icon: Icons.chevron_left_rounded,
              onPressed: () => onChangeMonth(-1),
            ),
            const SizedBox(width: 6),
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
                    color: theme.inkMuted,
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
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.08,
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
              isCompleted: habit.isCompletedOn(date),
              isSaving: savingDateKey == Habit.dateKeyFor(date),
              onTap: () => onToggleDate(date),
            );
          },
        ),
      ],
    );
  }
}

class _MonthArrowButton extends StatelessWidget {
  const _MonthArrowButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = _DailyThemeScope.of(context);

    return Material(
      color: theme.panel,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: theme.accentStrong, size: 18),
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
    required this.isCompleted,
    required this.isSaving,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool isCompleted;
  final bool isSaving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = _DailyThemeScope.of(context);
    final textColor = isCompleted ? Colors.white : theme.ink;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: isCompleted
                ? LinearGradient(
                    colors: [theme.accent, theme.accentAlt],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isCompleted ? null : theme.dayCellSurface,
            border: Border.all(
              color: isSelected
                  ? theme.accentStrong
                  : isToday
                  ? theme.accent.withValues(alpha: 0.55)
                  : theme.dayCellBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSaving)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isCompleted ? Colors.white : theme.accentStrong,
                  ),
                )
              else
                Text(
                  '${date.day}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: isToday || isCompleted ? 6 : 0,
                height: isToday || isCompleted ? 6 : 0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.white
                      : theme.accent.withValues(alpha: isToday ? 1 : 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDialog extends StatelessWidget {
  const _SettingsDialog({
    required this.completedCount,
    required this.totalCount,
    required this.savedLabel,
    required this.syncTitle,
    required this.syncDetail,
    required this.isBridgeConnected,
    required this.isImporting,
    required this.isExporting,
    required this.selectedTheme,
    required this.onThemeChanged,
    required this.onImport,
    required this.onExport,
  });

  final int completedCount;
  final int totalCount;
  final String savedLabel;
  final String syncTitle;
  final String syncDetail;
  final bool isBridgeConnected;
  final bool isImporting;
  final bool isExporting;
  final DailyThemeChoice selectedTheme;
  final ValueChanged<DailyThemeChoice> onThemeChanged;
  final VoidCallback onImport;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final theme = _DailyThemeScope.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
          decoration: BoxDecoration(
            color: theme.canvas,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: theme.glassShadow,
                blurRadius: 42,
                offset: Offset(0, 24),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '设置',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: theme.ink,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    IconButton(
                      tooltip: '关闭',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: theme.accentStrong,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  '主题配色',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: theme.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                _ThemeOptionList(
                  selectedTheme: selectedTheme,
                  onThemeChanged: onThemeChanged,
                ),
                const SizedBox(height: 22),
                Text(
                  '同步',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: theme.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                _SyncStatusCard(
                  title: syncTitle,
                  detail: syncDetail,
                  isConnected: isBridgeConnected,
                ),
                const SizedBox(height: 22),
                Text(
                  '数据',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: theme.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _WarmMetricChip(
                      label: '今天已完成 $completedCount / $totalCount',
                    ),
                    _WarmMetricChip(label: savedLabel),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _SettingsActionButton(
                        label: '导入备份',
                        icon: Icons.file_open_outlined,
                        isBusy: isImporting,
                        onPressed: isImporting ? null : onImport,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SettingsActionButton(
                        label: '导出备份',
                        icon: Icons.download_rounded,
                        isBusy: isExporting,
                        onPressed: isExporting ? null : onExport,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeOptionList extends StatelessWidget {
  const _ThemeOptionList({
    required this.selectedTheme,
    required this.onThemeChanged,
  });

  final DailyThemeChoice selectedTheme;
  final ValueChanged<DailyThemeChoice> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final choice in DailyThemeChoice.values) ...[
          _ThemeOptionTile(
            spec: _themeFor(choice),
            isSelected: selectedTheme == choice,
            onTap: () => onThemeChanged(choice),
          ),
          if (choice != DailyThemeChoice.values.last)
            const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.spec,
    required this.isSelected,
    required this.onTap,
  });

  final DailyThemeSpec spec;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = _DailyThemeScope.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.panelAlt
            : theme.panelAlt.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? theme.accent.withValues(alpha: 0.52)
              : theme.chipBorder,
          width: isSelected ? 1.4 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: theme.glassShadow.withValues(alpha: 0.58),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: spec.backgroundColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: spec.glassBorder),
                  ),
                  child: Center(
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [spec.accent, spec.accentAlt],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spec.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: theme.ink,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        spec.caption,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: theme.inkMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedScale(
                  duration: const Duration(milliseconds: 160),
                  scale: isSelected ? 1 : 0.78,
                  child: Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: isSelected ? theme.accentStrong : theme.inkMuted,
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

class _SyncStatusCard extends StatelessWidget {
  const _SyncStatusCard({
    required this.title,
    required this.detail,
    required this.isConnected,
  });

  final String title;
  final String detail;
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    final theme = _DailyThemeScope.of(context);
    final statusColor = isConnected ? const Color(0xFF16A34A) : theme.accentAlt;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.panelAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: theme.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: theme.inkMuted,
                    fontWeight: FontWeight.w600,
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

class _SettingsActionButton extends StatelessWidget {
  const _SettingsActionButton({
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
    return FilledButton.icon(
      onPressed: onPressed,
      icon: isBusy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _WarmMetricChip extends StatelessWidget {
  const _WarmMetricChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = _DailyThemeScope.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.chipSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.chipBorder),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: theme.inkMuted,
          fontWeight: FontWeight.w700,
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
    final theme = _DailyThemeScope.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              colors: [theme.glassTop, theme.glassBottom],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: theme.glassBorder),
            boxShadow: [
              BoxShadow(
                color: theme.glassShadow,
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
  const _AmbientGlow({required this.size, required this.colors});

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

class _SettingsFloatingButton extends StatelessWidget {
  const _SettingsFloatingButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = _DailyThemeScope.of(context);

    return _GlassPanel(
      padding: EdgeInsets.zero,
      borderRadius: 22,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.glassControl,
                    border: Border.all(color: theme.glassBorder),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 17,
                    color: theme.onBackground,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '设置',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: theme.onBackground,
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

class _GlassFloatingButton extends StatelessWidget {
  const _GlassFloatingButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = _DailyThemeScope.of(context);

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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [theme.accent, theme.accentAlt],
                    ),
                  ),
                  child: const Icon(Icons.add, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  '添加习惯',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: theme.onBackground,
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
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = _DailyThemeScope.of(context);

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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [theme.accent, theme.accentAlt],
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
                  color: theme.onBackground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '先创建一个习惯。之后点开习惯卡片，就能在日历里补记或取消任意一天。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: theme.onBackgroundMuted,
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
    required this.today,
    required this.onOpenCalendar,
    required this.onToggleToday,
    required this.onEdit,
    required this.onDelete,
  });

  final Habit habit;
  final DateTime today;
  final VoidCallback onOpenCalendar;
  final VoidCallback onToggleToday;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = _DailyThemeScope.of(context);
    final isCompleted = habit.isCompletedOn(today);
    final completedThisMonth = habit.completedCountInMonth(today);

    return _GlassPanel(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpenCalendar,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      key: ValueKey('habit-toggle-${habit.id}'),
                      onTap: onToggleToday,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isCompleted
                              ? LinearGradient(
                                  colors: [theme.accent, theme.accentAlt],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isCompleted ? null : theme.cardControl,
                          border: Border.all(color: theme.glassBorder),
                        ),
                        child: Icon(
                          isCompleted
                              ? Icons.check_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: theme.onBackground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: theme.onBackground,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 8),
                          _StatusChip(
                            label: isCompleted ? '今天已完成' : '今天未完成',
                            isCompleted: isCompleted,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${_selectedDateLabel(today)} · 点卡片查看打卡日历',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: theme.onBackgroundSoft),
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
                      onPressed: onOpenCalendar,
                      icon: Icons.calendar_month_rounded,
                      label: '日历',
                    ),
                    _GlassActionButton(
                      onPressed: onToggleToday,
                      icon: isCompleted
                          ? Icons.remove_done_rounded
                          : Icons.check_circle_outline_rounded,
                      label: isCompleted ? '取消今天' : '完成今天',
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
                      foregroundColor: theme.onBackgroundMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.isCompleted});

  final String label;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = _DailyThemeScope.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: isCompleted
            ? LinearGradient(colors: [theme.accent, theme.accentAlt])
            : null,
        color: isCompleted ? null : theme.cardControl,
        border: Border.all(color: theme.glassBorder),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: isCompleted ? Colors.white : theme.onBackground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = _DailyThemeScope.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardControl,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.glassBorder),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: theme.onBackgroundMuted),
      ),
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  const _GlassActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.foregroundColor,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = _DailyThemeScope.of(context);
    final color = foregroundColor ?? theme.onBackground;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardControl,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.glassBorder),
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
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
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
