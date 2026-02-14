import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'models/reminder.dart';

void upcomingWindowMain(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await _configureUpcomingWindow();

  runApp(const UpcomingWindowApp());
}

Future<void> _configureUpcomingWindow() async {
  const options = WindowOptions(
    size: Size(300, 96),
    minimumSize: Size(260, 78),
    maximumSize: Size(420, 140),
    skipTaskbar: true,
    alwaysOnTop: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
    title: 'SNotice - 即将到期提醒',
  );

  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setSkipTaskbar(true);
    await windowManager.setResizable(false);
    await windowManager.setPreventClose(true);
    await windowManager.setHasShadow(false);
    await windowManager.setOpacity(1.0);
    await windowManager.show(inactive: true);
  });
}

class UpcomingWindowApp extends StatelessWidget {
  const UpcomingWindowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SNotice Upcoming',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const UpcomingWindowScreen(),
    );
  }
}

class UpcomingWindowScreen extends StatefulWidget {
  const UpcomingWindowScreen({super.key});

  @override
  State<UpcomingWindowScreen> createState() => _UpcomingWindowScreenState();
}

class _UpcomingWindowScreenState extends State<UpcomingWindowScreen>
    with WindowListener {
  static const String _positionPinnedKey = 'upcoming_window_position_pinned';
  static const String _positionXKey = 'upcoming_window_position_x';
  static const String _positionYKey = 'upcoming_window_position_y';
  static const String _allWorkspacesKey = 'upcoming_window_all_workspaces';

  Reminder? _nextReminder;
  late final Future<SharedPreferences> _prefsFuture;
  Timer? _refreshTimer;
  bool _isPositionPinned = false;
  bool _showOnAllWorkspaces = true;
  bool _isApplyingWindowState = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _prefsFuture = SharedPreferences.getInstance();
    _loadWindowState();
    _startRefreshTimer();
  }

  @override
  void onWindowClose() async {
    await windowManager.hide();
  }

  @override
  void onWindowMoved() {
    _saveCurrentPosition();
  }

  void _startRefreshTimer() {
    _refreshReminders();
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _refreshReminders();
    });
  }

  Future<void> _refreshReminders() async {
    try {
      final prefs = await _prefsFuture;
      final remindersJson = prefs.getString('reminders');

      if (remindersJson == null || remindersJson.isEmpty) {
        if (!mounted || _nextReminder == null) return;
        setState(() {
          _nextReminder = null;
        });
        return;
      }

      final decoded = jsonDecode(remindersJson);
      if (decoded is! List) {
        return;
      }

      final loaded =
          decoded
              .whereType<Map>()
              .map(
                (item) => Reminder.fromJson(
                  item.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .where((reminder) => !reminder.isExpired)
              .toList()
            ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      if (!mounted) return;
      setState(() {
        _nextReminder = loaded.isEmpty ? null : loaded.first;
      });
    } catch (_) {
      // Ignore malformed storage payloads.
    }
  }

  Future<void> _loadWindowState() async {
    final prefs = await _prefsFuture;
    final positionPinned = prefs.getBool(_positionPinnedKey) ?? false;
    final showOnAllWorkspaces = prefs.getBool(_allWorkspacesKey) ?? true;
    final x = prefs.getDouble(_positionXKey);
    final y = prefs.getDouble(_positionYKey);

    if (mounted) {
      setState(() {
        _isPositionPinned = positionPinned;
        _showOnAllWorkspaces = showOnAllWorkspaces;
      });
    }

    if (positionPinned && x != null && y != null) {
      await windowManager.setPosition(Offset(x, y));
    }

    await _applyWindowState();
  }

  Future<void> _applyWindowState() async {
    if (_isApplyingWindowState) return;
    _isApplyingWindowState = true;
    try {
      await windowManager.setAlwaysOnTop(true);
      if (Platform.isMacOS) {
        await windowManager.setMovable(!_isPositionPinned);
      }
      if (Platform.isMacOS) {
        await windowManager.setVisibleOnAllWorkspaces(
          _showOnAllWorkspaces,
          visibleOnFullScreen: true,
        );
      }
    } finally {
      _isApplyingWindowState = false;
    }
  }

  Future<void> _saveCurrentPosition() async {
    if (!_isPositionPinned) return;
    try {
      final position = await windowManager.getPosition();
      final prefs = await _prefsFuture;
      await prefs.setDouble(_positionXKey, position.dx);
      await prefs.setDouble(_positionYKey, position.dy);
    } catch (_) {
      // Ignore position write failures.
    }
  }

  Future<void> _togglePinPosition() async {
    final nextValue = !_isPositionPinned;
    setState(() {
      _isPositionPinned = nextValue;
    });

    final prefs = await _prefsFuture;
    await prefs.setBool(_positionPinnedKey, nextValue);
    if (nextValue) {
      await _saveCurrentPosition();
    }

    await _applyWindowState();
  }

  Future<void> _toggleWorkspaces() async {
    final nextValue = !_showOnAllWorkspaces;
    setState(() {
      _showOnAllWorkspaces = nextValue;
    });

    final prefs = await _prefsFuture;
    await prefs.setBool(_allWorkspacesKey, nextValue);
    await _applyWindowState();
  }

  @override
  Widget build(BuildContext context) {
    final reminder = _nextReminder;
    final header = Row(
      children: [
        Icon(
          Icons.schedule,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            reminder == null ? '暂无即将到期提醒' : reminder.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          tooltip: _isPositionPinned ? '取消固定位置' : '固定当前位置',
          visualDensity: VisualDensity.compact,
          onPressed: _togglePinPosition,
          icon: Icon(
            _isPositionPinned ? Icons.push_pin : Icons.push_pin_outlined,
            size: 17,
          ),
        ),
        if (Platform.isMacOS)
          IconButton(
            tooltip: _showOnAllWorkspaces ? '关闭跨空间显示' : '开启跨空间显示',
            visualDensity: VisualDensity.compact,
            onPressed: _toggleWorkspaces,
            icon: Icon(
              _showOnAllWorkspaces ? Icons.layers : Icons.layers_clear,
              size: 17,
            ),
          ),
        IconButton(
          tooltip: '隐藏',
          visualDensity: VisualDensity.compact,
          onPressed: () async {
            await windowManager.hide();
          },
          icon: const Icon(Icons.close, size: 17),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isPositionPinned ? header : DragToMoveArea(child: header),
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  reminder == null
                      ? '点击图钉可固定位置'
                      : '剩余 ${reminder.timeRemaining} · 到期 ${_formatDateTime(reminder.scheduledTime)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    windowManager.removeListener(this);
    super.dispose();
  }
}

String _formatDateTime(DateTime dateTime) {
  final hh = dateTime.hour.toString().padLeft(2, '0');
  final mm = dateTime.minute.toString().padLeft(2, '0');
  final now = DateTime.now();

  if (now.year == dateTime.year &&
      now.month == dateTime.month &&
      now.day == dateTime.day) {
    return '今天 $hh:$mm';
  }

  return '${dateTime.month}/${dateTime.day} $hh:$mm';
}
