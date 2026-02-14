import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';
import '../models/reminder_template.dart';
import '../models/repeat_rule.dart';
import '../models/notification_request.dart';
import '../services/logger_service.dart';
import '../services/notification_service.dart';
import '../services/stats_service.dart';

class ReminderProvider extends ChangeNotifier {
  final LoggerService _logger;
  final NotificationService _notificationService;
  final StatsService _statsService;
  final List<Reminder> _reminders = [];
  final Set<String> _triggeredReminders = {};
  Timer? _timer;

  ReminderProvider(
    this._logger,
    this._notificationService,
    this._statsService,
  ) {
    _init();
  }

  List<Reminder> get activeReminders =>
      _reminders.where((r) => !r.isExpired).toList();

  List<Reminder> get expiredReminders =>
      _reminders.where((r) => r.isExpired).toList();

  /// 获取所有提醒（包括历史）
  List<Reminder> get allReminders => List.unmodifiable(_reminders);

  Future<void> _init() async {
    await _loadReminders();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkExpiredReminders();
    });
  }

  void _checkExpiredReminders() {
    final expiredReminders = _reminders
        .where((r) => r.isExpired && !_triggeredReminders.contains(r.id))
        .toList();

    for (final reminder in expiredReminders) {
      _triggeredReminders.add(reminder.id);
      unawaited(_triggerReminder(reminder));

      // 处理重复提醒：调度下一次
      if (reminder.isRepeating) {
        unawaited(_scheduleNextOccurrence(reminder));
      }
    }

    if (expiredReminders.isNotEmpty || _reminders.any((r) => !r.isExpired)) {
      notifyListeners();
    }
  }

  Future<void> _loadReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getString('reminders');
      if (remindersJson != null) {
        final List<dynamic> jsonList = jsonDecode(remindersJson);
        _reminders.clear();
        _reminders.addAll(
          jsonList.map(
            (json) => Reminder.fromJson(json as Map<String, dynamic>),
          ),
        );
        notifyListeners();
        _checkExpiredReminders();
      }
    } catch (e) {
      _logger.error('Failed to load reminders: $e');
    }
  }

  Future<void> _saveReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = jsonEncode(
        _reminders.map((r) => r.toJson()).toList(),
      );
      await prefs.setString('reminders', remindersJson);
    } catch (e) {
      _logger.error('Failed to save reminders: $e');
    }
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_reminders.length}';
  }

  /// 添加提醒
  Reminder addReminder({
    required String title,
    required String body,
    required Duration delay,
    String type = 'notification',
    String? flashColor,
    int? flashDuration,
    RepeatRule? repeatRule,
    String? templateId,
    String? soundKey,
  }) {
    return addReminderAt(
      title: title,
      body: body,
      scheduledTime: DateTime.now().add(delay),
      type: type,
      flashColor: flashColor,
      flashDuration: flashDuration,
      repeatRule: repeatRule,
      templateId: templateId,
      soundKey: soundKey,
    );
  }

  /// 按指定时间添加提醒
  Reminder addReminderAt({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String type = 'notification',
    String? flashColor,
    int? flashDuration,
    RepeatRule? repeatRule,
    String? templateId,
    String? soundKey,
  }) {
    final reminder = Reminder(
      id: _generateId(),
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      createdAt: DateTime.now(),
      type: type,
      flashColor: flashColor,
      flashDuration: flashDuration,
      repeatRule: repeatRule,
      templateId: templateId,
      soundKey: soundKey,
    );

    _reminders.add(reminder);
    _saveReminders();
    notifyListeners();

    // 记录统计事件
    unawaited(_statsService.recordEvent(reminder, 'created'));

    _logger.info(
      'Reminder added: ${reminder.title} at ${reminder.scheduledTime}',
    );

    return reminder;
  }

  /// 从模板创建提醒
  Reminder createFromTemplate(
    ReminderTemplate template, {
    String? customTitle,
    String? customBody,
    Duration? customDelay,
  }) {
    return addReminder(
      title: customTitle ?? template.defaultTitle,
      body: customBody ?? template.defaultBody,
      delay: customDelay ?? Duration(minutes: template.delayMinutes),
      type: template.type,
      flashColor: template.flashColor,
      flashDuration: template.flashDuration,
      templateId: template.id,
      soundKey: template.soundKey,
    );
  }

  Future<void> _triggerReminder(Reminder reminder) async {
    if (!_reminders.any((r) => r.id == reminder.id)) {
      return;
    }

    _logger.info('Reminder triggered: ${reminder.title}');

    // Show notification or flash screen based on type
    final request = NotificationRequest(
      title: reminder.title,
      body: reminder.body,
      priority: 'normal',
      category: reminder.type == 'flash' ? 'flash' : 'info',
      flashColor: reminder.flashColor,
      flashDuration: reminder.flashDuration,
    );

    await _notificationService.showNotification(request);

    // 记录统计事件
    unawaited(_statsService.recordEvent(reminder, 'triggered'));

    notifyListeners();
  }

  void removeReminder(String id) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final reminder = _reminders[index];
      _reminders.removeAt(index);
      _triggeredReminders.remove(id);
      _saveReminders();
      notifyListeners();

      // 记录统计事件
      unawaited(_statsService.recordEvent(reminder, 'cancelled'));

      _logger.info('Reminder removed: ${reminder.title}');
    }
  }

  /// 贪睡功能 - 将提醒延后指定时间
  void snooze(String id, Duration duration) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final reminder = _reminders[index];
      final newReminder = reminder.copyWith(
        scheduledTime: DateTime.now().add(duration),
      );
      _reminders[index] = newReminder;
      _triggeredReminders.remove(id);
      _saveReminders();
      notifyListeners();
      _logger.info('Reminder snoozed: ${reminder.title} for $duration');
    }
  }

  /// 关联两个提醒
  void linkReminders(String id1, String id2) {
    final index1 = _reminders.indexWhere((r) => r.id == id1);
    final index2 = _reminders.indexWhere((r) => r.id == id2);

    if (index1 == -1 || index2 == -1) return;

    final reminder1 = _reminders[index1];
    final reminder2 = _reminders[index2];

    _reminders[index1] = reminder1.copyWith(
      relatedIds: [...reminder1.relatedIds, id2],
    );
    _reminders[index2] = reminder2.copyWith(
      relatedIds: [...reminder2.relatedIds, id1],
    );

    _saveReminders();
    notifyListeners();
    _logger.info('Linked reminders: $id1 <-> $id2');
  }

  /// 获取关联的提醒
  List<Reminder> getRelated(String id) {
    final reminder = _reminders.where((r) => r.id == id).firstOrNull;
    if (reminder == null) return [];

    return _reminders.where((r) => reminder.relatedIds.contains(r.id)).toList();
  }

  /// 计算重复提醒的下次触发时间
  DateTime? _calculateNextTime(Reminder reminder) {
    if (reminder.repeatRule == null) return null;

    final rule = reminder.repeatRule!;
    final current = reminder.scheduledTime;

    // 检查是否超过结束日期
    if (rule.endDate != null && current.isAfter(rule.endDate!)) {
      return null;
    }

    // 检查是否超过最大次数
    if (rule.maxCount != null && reminder.occurrenceIndex >= rule.maxCount!) {
      return null;
    }

    DateTime next;
    switch (rule.frequency) {
      case 'daily':
        next = current.add(Duration(days: rule.interval));
        break;
      case 'weekly':
        if (rule.weekdays != null && rule.weekdays!.isNotEmpty) {
          // 找到下一个指定的星期几
          next = _findNextWeekday(current, rule.weekdays!, rule.interval);
        } else {
          next = current.add(Duration(days: 7 * rule.interval));
        }
        break;
      case 'monthly':
        next = _addMonths(current, rule.interval);
        break;
      case 'custom':
        // 自定义暂时按天处理
        next = current.add(Duration(days: rule.interval));
        break;
      default:
        return null;
    }

    // 再次检查结束日期
    if (rule.endDate != null && next.isAfter(rule.endDate!)) {
      return null;
    }

    return next;
  }

  /// 调度重复提醒的下一次
  Future<void> _scheduleNextOccurrence(Reminder reminder) async {
    final nextTime = _calculateNextTime(reminder);
    if (nextTime == null) {
      _logger.info('Repeating reminder ended: ${reminder.title}');
      return;
    }

    final nextReminder = Reminder(
      id: _generateId(),
      title: reminder.title,
      body: reminder.body,
      scheduledTime: nextTime,
      createdAt: DateTime.now(),
      type: reminder.type,
      flashColor: reminder.flashColor,
      flashDuration: reminder.flashDuration,
      repeatRule: reminder.repeatRule,
      templateId: reminder.templateId,
      soundKey: reminder.soundKey,
      parentReminderId: reminder.parentReminderId ?? reminder.id,
      occurrenceIndex: reminder.occurrenceIndex + 1,
    );

    _reminders.add(nextReminder);
    await _saveReminders();
    notifyListeners();

    _logger.info('Scheduled next occurrence of ${reminder.title} at $nextTime');
  }

  /// 找到下一个指定的星期几
  DateTime _findNextWeekday(
    DateTime current,
    List<int> weekdays,
    int interval,
  ) {
    final sortedWeekdays = weekdays.toList()..sort();
    var next = current.add(const Duration(days: 1));

    // 找到下一个匹配的星期几
    for (int i = 0; i < 7 * interval; i++) {
      final weekday = next.weekday;
      if (sortedWeekdays.contains(weekday)) {
        return next;
      }
      next = next.add(const Duration(days: 1));
    }

    // 如果没找到，返回当前时间 + interval 周
    return current.add(Duration(days: 7 * interval));
  }

  /// 添加月份
  DateTime _addMonths(DateTime date, int months) {
    int year = date.year;
    int month = date.month + months;

    while (month > 12) {
      month -= 12;
      year++;
    }

    // 处理日期溢出（如 1月31日 + 1月 = 2月28/29日）
    int day = date.day;
    final maxDay = DateTime(year, month + 1, 0).day;
    if (day > maxDay) {
      day = maxDay;
    }

    return DateTime(year, month, day, date.hour, date.minute, date.second);
  }

  void clearExpired() {
    final count = _reminders.length;
    final expiredIds = _reminders
        .where((r) => r.isExpired)
        .map((r) => r.id)
        .toSet();

    _reminders.removeWhere((r) => r.isExpired);
    _triggeredReminders.removeAll(expiredIds);
    final removed = count - _reminders.length;
    if (removed > 0) {
      _saveReminders();
      notifyListeners();
      _logger.info('Cleared $removed expired reminders');
    }
  }

  /// 清除所有提醒
  void clearAll() {
    _reminders.clear();
    _triggeredReminders.clear();
    _saveReminders();
    notifyListeners();
    _logger.info('Cleared all reminders');
  }

  /// 根据 ID 获取提醒
  Reminder? getById(String id) {
    try {
      return _reminders.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
